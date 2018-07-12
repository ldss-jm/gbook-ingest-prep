require_relative '../google_record'

class SierraItem
  attr_accessor :rec_data, :varfield_data
end

RSpec.describe GoogleRecord do
  describe 'my955' do
    bib = SierraBib.new('b1841152a')
    item = SierraItem.new('i2661010a')
    item.rec_data = {
      itype_code_num: "0",
      location_code: 'trln',
      item_status_code: "-",
      copy_num: "1",
      is_suppressed: "f"
    }
    item.varfield_data = [
      {id: "8978778", record_id: "450974227090", varfield_type_code: "b", marc_tag: nil, marc_ind1: " ", marc_ind2: " ", occ_num: "0", field_content: "00001254305"},
      {id: "8978779", record_id: "450974227090", varfield_type_code: "c", marc_tag: "090", marc_ind1: " ", marc_ind2: " ", occ_num: "0", field_content: "|aPR6056.A82 S6"},
      {id: "8978771", record_id: "450974227090", varfield_type_code: "v", marc_tag: nil, marc_ind1: " ", marc_ind2: " ", occ_num: "0", field_content: "v.2"},
      {id: "8978772", record_id: "450974227090", varfield_type_code: "z", marc_tag: nil, marc_ind1: " ", marc_ind2: " ", occ_num: "0", field_content: "public_note"}
    ]
    grec = GoogleRecord.new(bib, item)
    m955 = grec.my955

    it 'sets $b as barcode' do
      sftag = 'b'
      expect(m955[sftag]).to eq("00001254305")
    end

    it 'sets $v as volume' do
      sftag = 'v'
      expect(m955[sftag]).to eq("v.2")
    end

    it 'sets $a as callnum (without subfield delimiters)' do
      sftag = 'a'
      expect(m955[sftag]).to eq("PR6056.A82 S6")
    end

    it 'sets $z as public_notes' do
      sftag = 'z'
      expect(m955[sftag]).to eq("public_note")
    end

    it 'sets $i as inum_trunc' do
      sftag = 'i'
      expect(m955[sftag]).to eq("i2661010")
    end

    it 'sets $l as location code' do
      sftag = 'l'
      expect(m955[sftag]).to eq("trln")
    end

    it 'sets $s as status _description_' do
      sftag = 's'
      expect(m955[sftag]).to eq("Available")
    end

    it 'sets $t as itype _description_' do
      sftag = 't'
      expect(m955[sftag]).to eq("Book")
    end

    it 'sets $c as copy number' do
      sftag = 'c'
      expect(m955[sftag]).to eq("1")
    end
  end

  describe 'check_marc' do
    bib = SierraBib.new('b1841152a')
    item = SierraItem.new('i2661010a')
    item.rec_data = {
      itype_code_num: "0",
      location_code: 'trln',
      item_status_code: "w",
      copy_num: "1",
      is_suppressed: "t"
    }
    grec = GoogleRecord.new(bib, item)
    grec.check_marc

    it 'warns when suppressed' do
      expect(grec.warnings.include?('Item record is suppressed')).to be true
    end

    it 'warns when withdrawn' do
      expect(grec.warnings.include?('Item record is withdrawn')).to be true
    end

    context 'is not suppressed or withdrawn' do
      item2 = SierraItem.new('i2661010a')
      item2.rec_data = {
        itype_code_num: "0",
        location_code: 'trln',
        item_status_code: "-",
        copy_num: "1",
        is_suppressed: "f"
      }
      grec2 = GoogleRecord.new(bib, item2)
      grec2.check_marc

      it 'has no warnings' do
        expect(grec2.warnings.empty?).to be true
      end
    end
  end
end
