require 'spec_helper'

describe Sidekiq::Addons do
  it 'has a version number' do
    expect(Sidekiq::Addons::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
