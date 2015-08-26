require "spec_helper"

describe Transferatu::Mediators::Transfers::Purger do
  let(:group)     { create(:group) }
  let(:xfer)      { create(:transfer,
                           group: group,
                           to_type: 'gof3r',
                           deleted_at: Time.now) }

  let(:aws_key_id) { 'my-key-id' }
  let(:aws_secret) { 'my-key-secret' }
  let(:s3_client)  { double(:s3_client) }

  before do
    allow(Config).to receive(:aws_access_key_id).and_return(aws_key_id)
    allow(Config).to receive(:aws_secret_access_key).and_return(aws_secret)
    allow(Aws::S3::Client).to receive(:new)
                               .with(access_key_id: aws_key_id,
                                     secret_access_key: aws_secret,
                                     region: 'us-east-1')
                               .and_return(s3_client)
  end

  it "refuses to purge non-deleted transfers" do
    xfer.update(deleted_at: nil)
    expect do
      Transferatu::Mediators::Transfers::Purger.run(transfer: xfer)
    end.to raise_error(ArgumentError)
  end

  it "refuses to purge non-gof3r transfers" do
    xfer.update(to_type: 'pg_restore')
    expect do
      Transferatu::Mediators::Transfers::Purger.run(transfer: xfer)
    end.to raise_error(ArgumentError)
  end

  it "purges deleted transfers" do
    before = Time.now
    transfer_url = URI.parse(xfer.to_url)
    bucket = transfer_url.hostname.split('.').first
    object_id = transfer_url.path[1..-1]

    expect(s3_client).to receive(:delete_object)
                          .with(bucket: bucket, key: object_id)

    Transferatu::Mediators::Transfers::Purger.run(transfer: xfer)
    expect(xfer.purged_at).to_not be_nil
    expect(xfer.purged_at).to be > before
  end
end
