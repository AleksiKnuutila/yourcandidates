class CandidatesController < ApplicationController
  require 'uk_postcode'
  require 'json'
  require 'open-uri'

  POLICY_AREAS = [ 'NHS', 'UK Economy', 'Immigration', 'Benefits and pensions', 'Europe', 'Environment' ]
  PARTY_POLICIES = { 
    'Conservative Party' => { 
      'NHS' => 'For conservatives, the NHS is very important',
      'UK Economy' => 'For conservatives, the economy is very important',
      'Immigration' => [ [ 'Require European jobseekers to leave if they are unemployed after 6 months. Renegotiate the rules for free movement within the EU. Make migrants wait 4 years before claiming certain benefits or social housing.', 'http://press.conservatives.com/post/103802921280/david-cameron-speech-on-immigration' ], [ 'Reduce the incentives for people to move to the UK, with the aim of lowering net immigration to below 100,000 people a year (currently 243,000).', 'https://www.conservatives.com/Plan/CapWelfareReduceImmigration.aspx' ] ],
      'Benefits and pensions' => 'For conservatives, welfare is very important',
      'Europe' => 'For conservatives, europe is very important',
      'Environment' => 'For conservatives, the environment is very important',
    },
    'Labour Party' => {
      'NHS' => 'For labour, the NHS is very important',
      'UK Economy' => 'For labour, the economy is very important',
      'Immigration' => [ ['Establish stronger border control to reduce illegal immigration, with "proper" entry adn exit checks. Reduce low-skilled migration with "smarter targets", while ensuring university students and high-skilled workers can migrate. Increase fines for employing illegal immigrants, and outlaw employment agencies recruiting only abroad.', 'http://press.labour.org.uk/post/98301589749/speech-by-yvette-cooper-mp-to-labours-annual' ] ],
      'Benefits and pensions' => 'For labour, welfare is very important',
      'Europe' => 'For labour, europe is very important',
      'Environment' => 'For labour, the environment is very important',
    },
    'Liberal Democrats' => { 
      'NHS' => 'For libdems, the NHS is very important',
      'UK Economy' => 'For libdems, the economy is very important',
      'Immigration' => [ [ 'Reintroduce exit checks at UK borders, so the government can identify people overstaying their visa. Mandate people on unemployment benefits to take an English test, and require those who fail to attend English classes.', 'http://www.libdems.org.uk/nick_clegg_s_immigration_speech' ] ],
      'Benefits and pensions' => 'For libdems, welfare is very important',
      'Europe' => 'For libdems, europe is very important',
      'Environment' => 'For libdems, the environment is very important',
    },
    'Green Party' => {
      'NHS' => 'For greens, the NHS is very important',
      'UK Economy' => 'For greens, the economy is very important',
      'Immigration' => [ [ 'Reduce UK immigration controls over time. Migrants illegally in the UK for over five years will be allowed to remain unless they pose a serious danger to public safety.', 'http://policy.greenparty.org.uk/mg.html' ], [ 'Increase legal rights of asylum seekers.', 'http://policy.greenparty.org.uk/ra.html' ] ],
      'Benefits and pensions' => 'For greens, welfare is very important',
      'Europe' => 'For greens, europe is very important',
      'Environment' => 'For greens, the environment is very important',
    },
    'UK Independence Party (UKIP)' => {
      'NHS' => 'For ukip, the NHS is very important',
      'UK Economy' => 'For ukip, the economy is very important',
      'Immigration' => [ [ 'Like in Australia, choose immigrants based on a system of points, reflecting skills needed for work in the country. Apply points system to both EU and non-EU immigrants. Reduce net immigration to 50,000 people a year. Make language skill tests for residence permits harder. To allow the UK to return asylum seekers to other EU countries without hearing their case, opt out of the Dublin treaty.', 'http://www.ukip.org/steven_woolfe_ukip_s_ethical_migration_policy' ], [ 'People who currently are in the UK legally would not be deported, were the UK to leave the EU.', '' ] ],
      'Benefits and pensions' => 'For ukip, welfare is very important',
      'Europe' => 'For ukip, europe is very important',
      'Environment' => 'For ukip, the environment is very important',
    },
    'Scottish National Party' => {
      'NHS' => 'For SNP, the NHS is very important',
      'UK Economy' => 'For SNP, the economy is very important',
      'Immigration' => [ [ 'Give the devolved Scottish government control over immigration to Scotland. Use a Canadian-style "earned citizenship system" to attract high-skilled workers.', '' ] ],
      'Benefits and pensions' => 'For SNP, welfare is very important',
      'Europe' => 'For SNP, europe is very important',
      'Environment' => 'For SNP, the environment is very important',
    },
    'Plaid Cymru' => {
      'NHS' => 'For plaid cymru, the NHS is very important',
      'UK Economy' => 'For plaid cymru, the economy is very important',
      'Immigration' => [ [ 'Opposes a choice of immigrants following a "point-based system", as it would not reflect Welsh needs. Asylum seekers should be able to work in Wales while waiting for their status decision. UK government should close "detention centres".', 'http://www.partyof.wales/our-vision-for-a-better-society/?force=1' ] ],
      'Benefits and pensions' => 'For plaid cymru, welfare is very important',
      'Europe' => 'For plaid cymru, europe is very important',
      'Environment' => 'For plaid cymru, the environment is very important',
    },
    'Default' => {
      'NHS' => 'No information about NHS yet',
      'UK Economy' => 'No information about economy yet',
      'Immigration' => 'No information about immigration yet',
      'Benefits and pensions' => 'No information about benefits yet',
      'Europe' => 'No information about europe yet',
      'Environment' => 'No information about environment yet'
    }
  }

  def getConstituencyId(postcode)
    pc = UKPostcode.new(postcode)
    if not pc.valid?
      return false
    end
    uri = 'http://mapit.mysociety.org/postcode/'+pc.outcode+pc.incode
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    return @data['shortcuts']['WMC']
  end

  def isIncumbentMP(candidate)
    # Is the best way to check this to look at the public whip identifier?
    for ide in candidate['identifiers']
      if ide['scheme'] == 'uk.org.publicwhip'
        return true
      end
    end
    return false
  end

  def getPolicy(candidate, policyArea)
    party = candidate['party_memberships']['2015']['name']
    if not PARTY_POLICIES.key?(party)
      party = 'Default'
    end
    return PARTY_POLICIES[party][policyArea]
  end

  def getAllPolicies(candidates)
    policies = Hash.new
    for candidate in candidates
      policies[candidate['id']] = Hash.new
      for policy in POLICY_AREAS
        policies[candidate['id']][policy] = getPolicy(candidate, policy)
      end
    end
    return policies
  end

  def getImageUrl(candidate)
    if candidate['image']
      return candidate['image']
    end
#    if candidate['person_id']['image']
#      return candidate['person_id']['image']
#    end
    return nil
# TODO: Add twitter image search here
  end

  def getCandidates(constituencyId)
    uri = 'http://yournextmp.popit.mysociety.org/api/v0.1/posts/'+constituencyId.to_s+'?embed=membership.person'
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    @candidates = []
    for cand in @data['result']['memberships']
      @currentConstituency = cand['person_id']['versions'][0]['data']['standing_in']['2015']
      if @currentConstituency and @currentConstituency['post_id'] == constituencyId.to_s
        # merge to make sure versions[0][data] is easily accessible in object - not ideal!
        @candidates.concat([cand['person_id']['versions'][0]['data'].merge(cand['person_id'])])
      end
    end
    # For some reason there are duplicates in the JSON
    @candidates = @candidates.uniq
    for i in @candidates.each_index()
      @candidates[i]['image_url'] = getImageUrl(@candidates[i])
      @candidates[i]['isIncumbentMP'] = isIncumbentMP(@candidates[i])
    end
    return @candidates
  end

  def getCandidateById(id)
    uri = 'http://yournextmp.popit.mysociety.org/api/v0.1/search/persons?q=id:'+id.to_s
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    return @data['result'][0]
  end

  def index
    @q = request['q']
    @conId = getConstituencyId(@q)
    # TODO: add some kind of error here!
    if not @conId
      redirect_to "/" and return
    end
    @candidates = getCandidates(@conId)
    @policies = getAllPolicies(@candidates)
    @PARTY_POLICIES = PARTY_POLICIES
    # necessary?
    return ''
  end

  def show
    @candidate = getCandidateById(request['id'])
  end
end
