require "test_helper"
require "minitest/mock"

class RegulationsImporterTest < ActiveSupport::TestCase
  def setup
    @snapshot = DailySnapshot.create!(date: Date.today)
  end

  test "imports regulations and creates snapshot events" do
    xml_content = <<~XML
      <publication>
        <trafficRegulationOrder id="TEST-EXT-001">
          <issuingAuthority>
            <values>
              <value>Mairie de Test</value>
            </values>
          </issuingAuthority>
          <regulationId>REG-001</regulationId>
          <trafficRegulation>
            <typeOfRegulation type="SpeedLimit"/>
            <overallStartTime>2026-01-01T00:00:00</overallStartTime>
            <overallEndTime>2026-12-31T23:59:59</overallEndTime>
          </trafficRegulation>
        </trafficRegulationOrder>
      </publication>
    XML

    # Create instance
    importer = RegulationsImporter.new(daily_snapshot: @snapshot)

    # Stub fetch_stream on the instance
    importer.stub :fetch_stream, StringIO.new(xml_content) do
      assert_difference -> { Regulation.count }, 1 do
        # Execute perform on the instance
        importer.perform
      end
    end

    # Vérifications
    reg = Regulation.find_by(external_id: "TEST-EXT-001")
    assert_not_nil reg
    assert_equal "Mairie de Test", reg.organization.name
    assert_equal "SpeedLimit", reg.restrictions.first.restriction_type

    # Vérification des événements
    event = @snapshot.snapshot_events.find_by(regulation: reg)
    assert_not_nil event
    assert_equal "added", event.event_type
    assert_equal reg, event.regulation
    assert_equal reg.organization, event.organization
  end

  test "marks missing regulations as inactive and creates removed events" do
    # Préparez un arrêté existant qui ne sera PAS dans le XML (donc supprimé)
    org = Organization.create!(name: "Old Corp")
    old_reg = Regulation.create!(
      organization: org,
      external_id: "OLD-001",
      active: true,
      last_seen_at: 1.day.ago
    )

    empty_xml = "<publication></publication>"
    importer = RegulationsImporter.new(daily_snapshot: @snapshot)

    importer.stub :fetch_stream, StringIO.new(empty_xml) do
      # On s'attend à ce que old_reg devienne inactif
      importer.perform
    end

    old_reg.reload
    assert_not old_reg.active?

    # Vérification événement suppression
    event = @snapshot.snapshot_events.find_by(regulation: old_reg)
    assert_not_nil event
    assert_equal "removed", event.event_type
  end
end
