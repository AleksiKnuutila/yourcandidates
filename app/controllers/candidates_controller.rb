class CandidatesController < ApplicationController
  require 'uk_postcode'
  require 'json'
  require 'open-uri'
  require 'twitter'

  def getConstituencyByPC(postcode)
    pc = UKPostcode.new(postcode)
    if not pc.valid? or not pc.incode or not pc.outcode
      return false
    end
    uri = 'http://mapit.mysociety.org/postcode/'+pc.outcode+pc.incode
    begin
      # This will raise HTTPError if postcode is wrong
      jsondata = open(uri)
    rescue
      return nil
    end
    return JSON.load(jsondata)
  end

  def getConstituencyByCoords(lat,long)
    uri = 'http://mapit.mysociety.org/point/4326/'+long+','+lat+'?type=WMC'
    begin
      # This will raise HTTPError if postcode is wrong
      jsondata = open(uri)
    rescue
      return nil
    end
    return JSON.load(jsondata)
  end

  def getAllPredictions()
    uri = 'http://www.edu.lahti.fi/~zur/predictions-range.json'
    jsondata = open(uri)
    return JSON.load(jsondata)
  end

  def predictionRangeToValue(range)
    s = range.split('-')
    return (( s[0].to_i + s[1].to_f ) / 2).ceil
  end

  def makeRange(range)
    s = range.split('-')
    return s[0].to_i..s[1].to_i
  end

  def getPrediction(candidate, constituency)
    pred = @predictions.find { |c| c['name'] == constituency }
    if pred
      party = candidate['party']
      # In data, Scottish Greens are simply written in as Greens
      if party == 'Scottish Green Party'
        party = 'Green Party'
      end
      if not pred['parties'][party]
        return nil
      end
      # which party is doing best?
      means = {}
      pred['parties'].each { |k,v| means[k] = predictionRangeToValue(v) }
      ranges = {}
      pred['parties'].each { |k,v| ranges[k] = makeRange(v) }
      # Find range with highest upper limit
      max_range = ranges.values.max_by { |x| x.end }
      # Change displayed colour if ranges overlap
      if max_range.include?(ranges[party].end)
        maxval = true
      else
        maxval = false
      end
      return {'rangestring' => pred['parties'][party], 'value' => means[party], 'maxvalue' => maxval}
    end
    return nil
  end

  def getConstituencyByID(id)
    uri = 'http://mapit.mysociety.org/postcode/'+pc.outcode+pc.incode
    jsondata = open(uri)
    return JSON.load(jsondata)
  end

  def getMPid(candidate)
    # Is the best way to check this to look at the public whip identifier?
    for ide in candidate['identifiers']
      if ide['scheme'] == 'uk.org.publicwhip'
        # return numbers from end of the string
        return /[0-9]+$/.match(ide['identifier'])[0]
      end
    end
    return nil
  end

  def getPolicy(candidate, policyArea)
    party = candidate['party']
    if party == 'Independent'
      party = 'Independent - ' + candidate['name']
    end
    if CONSTITUENCY_POLICY.key?(@constituencyName) and CONSTITUENCY_POLICY[@constituencyName].key?(party)
      return CONSTITUENCY_POLICY[@constituencyName][party][policyArea]
    end
    if not PARTY_CONSTANTS.key?(party)
      party = 'Default'
    end
    if PARTY_CONSTANTS[party][policyArea].kind_of?(Array)
      return [['Party policy: ','']].concat(PARTY_CONSTANTS[party][policyArea])
    else
      return PARTY_CONSTANTS[party][policyArea]
    end
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

  def getImageUrl(candidate, twitter_obj)
    if candidate['image']
      return candidate['image']
    end
    if candidate['twitter_username'].length > 2
      begin
        twitter_user = twitter_obj.user(candidate['twitter_username'])
      rescue Twitter::Error::NotFound
        candidate['twitter_username'] = ''
        return nil
      end
      twitter_profile_uri = twitter_user.profile_image_uri.to_s.sub("_normal", "")
      if not twitter_profile_uri =~ /default_profile_images/
        return twitter_profile_uri
      end
    end
  end

  def getPreviousResults(candidate, const_name)
    const = Constituency.find_by_name(const_name)
    party = candidate['party']
    # In data, Scottish Greens are simply written in as Greens
    if party == 'Scottish Green Party'
      party = 'Green Party'
    end
    # Add special case for Independents here too
    if party == 'Independent'
      party = 'Independent - '+candidate['name']
    end
    if const.parties.has_key?(party)
      # Special way independents are coded
      return const.parties[party]
    else
      return nil
    end
  end

  def getPreviousElectionYear(candidates)
    for c in candidates
      if c['previousVote'] and c['previousVote']['year']
        return c['previousVote']['year']
      end
    end
  end

  def isEmptyCandidate(c)
    if c['MPid']
      return false
    elsif c['twitter_username'] and c['twitter_username'].length > 2
      return false
    elsif c['facebook_personal_url'] and c['facebook_personal_url'].length > 5
      return false
    elsif c['homepage_url'] and c['homepage_url'].length > 5
      return false
    elsif c['party_ppc_page_url'] and c['party_ppc_page_url'].length > 5
      return false
    elsif c['wikipedia_url'] and c['wikipedia_url'].length > 5
      return false
    elsif c['email'] and c['email'].length > 5
      return false
    end
    return true
  end

  def getCandidates(constituencyId, constituencyName)
    uri = 'http://yournextmp.popit.mysociety.org/api/v0.1/posts/'+constituencyId.to_s+'?embed=membership.person'
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = 'vzUdH63VDtZX1AQiUNBPpL0Sj'
      config.consumer_secret = 'gosJYtqmDduobc4QWVo4xL56ykro1sBvQlVbZVnuHwkxhwZFVd'
      config.access_token = '3006172181-DiGGfRtjGyHvwpl1k8jaR4o3uPEW2GQRdZwLwB0'
      config.access_token_secret = 'MCmGUPGi4jpMZS7795FRGp6JXdtDKwNr8EedbMzUY4JOA'
    end
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
      @candidates[i]['image_url'] = getImageUrl(@candidates[i], twitter_client)
      @candidates[i]['party'] = @candidates[i]['party_memberships']['2015']['name']
      @candidates[i]['isEmpty'] = isEmptyCandidate(@candidates[i])
      if PARTY_REPLACE_STRINGS[@candidates[i]['party']]
        @candidates[i]['party'] = PARTY_REPLACE_STRINGS[@candidates[i]['party']]
      end
      @candidates[i]['previousVote'] = getPreviousResults(@candidates[i], constituencyName)
      @candidates[i]['prediction2015'] = getPrediction(@candidates[i], constituencyName)
      @candidates[i]['MPid'] = getMPid(@candidates[i])
    end
    return @candidates
  end

  def getCandidateById(id)
    uri = 'http://yournextmp.popit.mysociety.org/api/v0.1/search/persons?q=id:'+id.to_s
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    return @data['result'][0]
  end

  def getTwitterCount(candidates)
    count = 0
    for c in candidates
      if c['twitter_username'] and c['twitter_username'].length > 2
        count = count + 1
      end
    end
    return count
  end

  def search
    if not request['q'] and not request['lat']
      redirect_to "/?error" and return
    end
    if request['lat']
      @condata = getConstituencyByCoords(request['lat'],request['long'])
      if not @condata.length > 0
        # flash[:alert] = "Location not in the UK?"
        redirect_to "/?err2" and return
      end
      @conId = @condata.keys[0].to_i
    else
      @q = request['q']
      @condata = getConstituencyByPC(@q)
      if not @condata
        # flash[:alert] = "Invalid post code, please try again"
        redirect_to "/?error" and return
      end
      @conId = @condata['shortcuts']['WMC']
    end
    redirect_to "/constituencies/"+TWITTER_LIST[@conId] and return
  end

  def index
    # TODO: This bit can be removed later..
    if request['q']
      @q = request['q']
      @condata = getConstituencyByPC(@q)
      if not @condata
        # flash[:alert] = "Invalid post code, please try again"
        redirect_to "/?error" and return
      end
      @conId = @condata['shortcuts']['WMC']
      @constituencyName = @condata['areas'][@conId.to_s]['name']
    elsif request['name']
      @constituencyName = CONSTITUENCY_LIST[request['name']][0]
      if not @constituencyName
        raise ActionController::RoutingError.new('Not Found')
      end
      @conId = CONSTITUENCY_LIST[request['name']][1]
    else
      # flash[:alert] = "Invalid post code, please try again"
      redirect_to "/?error" and return
    end
    @twitter_list = TWITTER_LIST[@conId]
    @predictions = Rails.cache.fetch('predictions', expires_in: 24.hours) { getAllPredictions() }
    @candidates = Rails.cache.fetch('candidates-'+@conId.to_s, expires_in: 24.hours) { getCandidates(@conId, @constituencyName) }
    @previousElectionYear = getPreviousElectionYear(@candidates)
    @twitter_count = getTwitterCount(@candidates)
    @policies = getAllPolicies(@candidates)
    @PARTY_CONSTANTS = PARTY_CONSTANTS
  end

  def constituencies
    @constituency_hash = CONSTITUENCY_LIST
  end

  def show
    @candidate = getCandidateById(request['id'])
  end
end
