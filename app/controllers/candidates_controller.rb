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

  def index
    @q = request['q']
    @conId = getConstituencyId(@q)
    @candidates = getCandidates(@conId)
    return 'test'
  end

  def show
  end
end
