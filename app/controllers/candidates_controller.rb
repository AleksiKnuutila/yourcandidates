class CandidatesController < ApplicationController
  require 'uk_postcode'
  require 'json'
  require 'open-uri'

  POLICY_AREAS = [ 'NHS', 'UK Economy', 'Immigration', 'Benefits and pensions', 'Europe', 'Environment' ]
  PARTY_POLICIES = { 
    'Conservative Party' => { 
      'NHS' => 'For conservatives, the NHS is very important',
      'UK Economy' => 'For conservatives, the economy is very important',
      'Immigration' => 'For conservatives, immigration is very important',
      'Benefits and pensions' => 'For conservatives, welfare is very important',
      'Europe' => 'For conservatives, europe is very important',
      'Environment' => 'For conservatives, the environment is very important',
    },
    'Labour Party' => {
      'NHS' => 'For labour, the NHS is very important',
      'UK Economy' => 'For labour, the economy is very important',
      'Immigration' => 'For labour, immigration is very important',
      'Benefits and pensions' => 'For labour, welfare is very important',
      'Europe' => 'For labour, europe is very important',
      'Environment' => 'For labour, the environment is very important',
    },
    'Liberal Democrats' => { 
      'NHS' => 'For libdems, the NHS is very important',
      'UK Economy' => 'For libdems, the economy is very important',
      'Immigration' => 'For libdems, immigration is very important',
      'Benefits and pensions' => 'For libdems, welfare is very important',
      'Europe' => 'For libdems, europe is very important',
      'Environment' => 'For libdems, the environment is very important',
    },
    'Green Party' => {
      'NHS' => 'For greens, the NHS is very important',
      'UK Economy' => 'For greens, the economy is very important',
      'Immigration' => 'For greens, immigration is very important',
      'Benefits and pensions' => 'For greens, welfare is very important',
      'Europe' => 'For greens, europe is very important',
      'Environment' => 'For greens, the environment is very important',
    },
    'UK Independence Party (UKIP)' => {
      'NHS' => 'For ukip, the NHS is very important',
      'UK Economy' => 'For ukip, the economy is very important',
      'Immigration' => 'For ukip, immigration is very important',
      'Benefits and pensions' => 'For ukip, welfare is very important',
      'Europe' => 'For ukip, europe is very important',
      'Environment' => 'For ukip, the environment is very important',
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

  def getCandidates(constituencyId)
    uri = 'http://yournextmp.popit.mysociety.org/api/v0.1/posts/'+constituencyId.to_s+'?embed=membership.person'
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    @candidates = []
    for cand in @data['result']['memberships']
      @currentConstituency = cand['person_id']['versions'][0]['data']['standing_in']['2015']
      if @currentConstituency and @currentConstituency['post_id'] == constituencyId.to_s
        @candidates.concat([cand['person_id']['versions'][0]['data']])
      end
    end
    # For some reason there are duplicates in the JSON
    @candidates = @candidates.uniq
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
    # necessary?
    return ''
  end

  def show
    @candidate = getCandidateById(request['id'])
  end
end
