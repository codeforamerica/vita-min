# == Schema Information
#
# Table name: efile_errors
#
#  id              :bigint           not null, primary key
#  auto_cancel     :boolean          default(FALSE)
#  auto_wait       :boolean          default(FALSE)
#  category        :string
#  code            :string
#  correction_path :string
#  expose          :boolean          default(FALSE)
#  message         :text
#  service_type    :integer          default("unfilled"), not null
#  severity        :string
#  source          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

describe 'EfileError' do
  it 'returns name dob as the default controller' do
    expect(EfileError.default_controller).to eq StateFile::Questions::NameDobController
  end

  it 'converts controllers to paths' do
    path = EfileError.controller_to_path(StateFile::Questions::NameDobController)
    expect(path).to eq "name-dob"
  end

  it 'converts paths to controllers' do
    controller = EfileError.path_to_controller("w2")
    expect(controller).to eq StateFile::Questions::W2Controller
  end
end
