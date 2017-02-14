require 'tt'

describe TT do
  let(:tt_3050) { TT.new(DateTime.new, 3050, 1, "A", "B", :ask) }
  let(:tt_3051) { TT.new(DateTime.new, 3051, 1, "C", "D", :bid) }
  let(:tt_3049) { TT.new(DateTime.new, 3049, 1, "E", "F", :bid) }

  describe "#is_uptic?" do
    context "given a tt with lower value" do
      it "return true if has a greater value" do
        expect(tt_3050.is_uptic?(tt_3049)).to be true
      end
    end
    context "given a tt with greater value" do
      it "return false if has a lower value" do
        expect(tt_3050.is_uptic?(tt_3051)).to be false
      end
    end
  end

  describe "#is_downtic?" do
    context "given a tt with lower value" do
      it "return false if has a greater value" do
        expect(tt_3050.is_downtic?(tt_3049)).to be false
      end
    end
    context "given a tt with greater value" do
      it "return true if has a lower value" do
        expect(tt_3050.is_downtic?(tt_3051)).to be true
      end
    end
  end

  describe "#is_equal_tic?" do
    context "given a tt with lower value" do
      it "return false if has a greater value" do
        expect(tt_3050.is_equal_tic?(tt_3049)).to be false
      end
    end
    context "given a tt with equal value" do
      it "return true if has a equal value" do
        expect(tt_3050.is_equal_tic?(tt_3050)).to be true
      end
    end
  end
end
