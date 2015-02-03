class CandidatesController < ApplicationController
  require 'uk_postcode'
  require 'json'
  require 'open-uri'

  POLICY_AREAS = [ 'Environment', 'Welfare', 'Immigration', 'Austerity' ]
  PARTY_POLICIES = { 
    'Conservative Party' => { 'Environment' => 'For conservatives, the environment is very important',
      'Welfare' => 'For conservatives, welfare is very important',
      'Immigration' => 'For conservatives, immigration is very important',
      'Austerity' => 'For conservatives, austerity is very important' },
    'Labour Party' => { 'Environment' => 'For labour, the environment is very important',
      'Welfare' => 'For labour, welfare is very important',
      'Immigration' => 'For labour, immigration is very important',
      'Austerity' => 'For labour, austerity is very important' },
    'Liberal Democrats' => { 'Environment' => 'For libdems, the environment is very important',
      'Welfare' => 'For libdems, welfare is very important',
      'Immigration' => 'For libdems, immigration is very important',
      'Austerity' => 'For libdems, austerity is very important' },
    'Green Party' => { 'Environment' => 'For greens, the environment is very important',
      'Welfare' => 'For greens, welfare is very important',
      'Immigration' => 'For greens, immigration is very important',
      'Austerity' => 'For greens, austerity is very important' },
    'UK Independence Party' => { 'Environment' => 'For ukip, the environment is very important',
      'Welfare' => 'For ukip, welfare is very important',
      'Immigration' => 'For ukip, immigration is very important',
      'Austerity' => 'For ukip, austerity is very important' },
    'Default' => { 'Environment' => 'No information about Environment',
      'Welfare' => 'No information about welfare',
      'Immigration' => 'No information about immigration',
      'Austerity' => 'No information about austerity' }
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
