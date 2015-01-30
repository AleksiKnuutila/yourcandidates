class CandidatesController < ApplicationController
  require 'uk_postcode'
  require 'json'
  require 'open-uri'

  def getConstituencyId(postcode)
    uri = 'http://mapit.mysociety.org/postcode/'+postcode
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    return @data['shortcuts']['WMC']
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
    @candidates = getCandidates(@conId)
    # necessary?
    return ''
  end

  def show
    @candidate = getCandidateById(request['id'])
  end
end
