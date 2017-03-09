require 'models/matrix_db'

describe MatrixDB do
  let(:matrix_db) { MatrixDB.new(["127.0.0.1"], database:"matrix_test") }

  before do
    matrix_db.on(:test).delete
  end

  describe "#delete" do
    context "given a collection and no filter" do
      it "erases all data" do
        data = [{ data:"test" }, { data:"test" }]
        matrix_db.on(:test).insert_many(data)

        matrix_db.delete

        result = matrix_db.on(:test).find({})
        matrix_db.close
        expect(result.count).to be 0
      end
    end

    context "given a collection and a specific filter" do
      it "erases data by flter" do
        data = [{ data:"test" }, { data:"testAAAA" }]
        matrix_db.on(:test).insert_many(data)

        matrix_db.delete({ data:"test" })

        result = matrix_db.on(:test).find({})
        matrix_db.close
        expect(result.count).to be 1
      end
    end
  end

  describe "#find" do
    context "given a collection and a filter" do
      it "finds data" do
        expected = { data:"test" }

        data = [expected, { data:"bla bla" }]
        matrix_db.on(:test).insert_many(data)
        result = matrix_db.on(:test).find(expected)
        matrix_db.close
        expect(result.first[:data]).to eq expected[:data]
      end
    end
  end

  describe "#insert_one" do
    context "given a collection and hash to be inserted" do
      it "inserts data into given collection" do
        matrix_db.on(:test).insert_one({ data:"test" })

        result = matrix_db.on(:test).find({ data:"test" })
        matrix_db.close
        expect(result.count).to be 1
      end
    end
  end

  describe "#insert_many" do
    context "given a collection and array to be inserted" do
      it "inserts all array data into given collection" do
        data = [{ data:"test" }, { data:"test" }]
        matrix_db.on(:test).insert_many(data)

        result = matrix_db.on(:test).find({ data:"test" })
        matrix_db.close
        expect(result.count).to be 2
      end
    end
  end

end
