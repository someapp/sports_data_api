require 'spec_helper'

describe SportsDataApi::Nfl::Team, vcr: {
    cassette_name: 'sports_data_api_nfl_team',
    record: :new_episodes,
    match_requests_on: [:host, :path]
} do
  let(:boxscore) do
    SportsDataApi.key = api_key
    SportsDataApi.access_level = 't'
    SportsDataApi::Nfl.boxscore(2012, :REG, 9, 'IND', 'MIA')
  end
  describe 'home team' do
    subject { boxscore.home_team }
    it { should be_an_instance_of(SportsDataApi::Nfl::Team) }
    its(:id) { should eq 'IND' }
    its(:name) { should eq 'Colts' }
    its(:market) { should eq 'Indianapolis' }
    its(:remaining_challenges) { should eq 1 }
    its(:remaining_timeouts) { should eq 2 }
    its(:score) { should eq 23 }
    its(:quarters) { should have(4).scores }
    its(:quarters) { should eq [7, 6, 7, 3] }
  end
  describe 'away team' do
    subject { boxscore.away_team }
    it { should be_an_instance_of(SportsDataApi::Nfl::Team) }
    its(:id) { should eq 'MIA' }
    its(:name) { should eq 'Dolphins' }
    its(:market) { should eq 'Miami' }
    its(:remaining_challenges) { should eq 2 }
    its(:remaining_timeouts) { should eq 2 }
    its(:score) { should eq 20 }
    its(:quarters) { should have(4).scores }
    its(:quarters) { should eq [3, 14, 0, 3] }
  end
  describe 'eql' do
    let(:url) { 'http://api.sportsdatallc.org/nfl-t1/teams/hierarchy.xml' }

    let(:dolphins_xml) do
      str = RestClient.get(url, params: { api_key: api_key }).to_s
      xml = Nokogiri::XML(str)
      xml.remove_namespaces!
      xml.xpath('/league/conference/division/team[@id=\'MIA\']')
    end

    let(:dolphins1) { SportsDataApi::Nfl::Team.new(dolphins_xml) }
    let(:dolphins2) { SportsDataApi::Nfl::Team.new(dolphins_xml) }

    it { (dolphins1 == dolphins2).should be_true }
  end
end
