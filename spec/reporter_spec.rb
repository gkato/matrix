require 'reporter'

describe Reporter do
  let(:possibilities) {[]}

  before do
    [4,6,2,1,3,5].to_a.each do |val|
      possibilities << {net:10*val, stop:val, start:val}
    end
  end

  describe ".by_possibility" do
    context "given all possibilities and its results" do
      it "prints 3 worst and 3 best possibilities" do
        expect(possibilities.first[:net]).to eq(40)

        Reporter.by_possibility(possibilities)

        expect(possibilities[0][:net]).to eq(10)
        expect(possibilities[1][:net]).to eq(20)
        expect(possibilities[2][:net]).to eq(30)
        expect(possibilities[3][:net]).to eq(40)
        expect(possibilities[4][:net]).to eq(50)
        expect(possibilities[5][:net]).to eq(60)
      end
    end
  end
end
