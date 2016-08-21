require 'spec_helper'

describe Sidekiq::Addons do
  it 'has a version number' do
    expect(Sidekiq::Addons::VERSION).not_to be nil
  end
end
