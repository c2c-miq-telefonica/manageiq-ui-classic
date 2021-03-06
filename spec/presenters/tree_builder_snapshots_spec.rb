describe TreeBuilderSnapshots do
  context 'TreeBuilderSnaphots' do
    before do
      role = MiqUserRole.find_by(:name => "EvmRole-operator")
      @group = FactoryBot.create(:miq_group, :miq_user_role => role, :description => "Snapshot Group")
      login_as FactoryBot.create(:user, :userid => 'snapshot_wilma', :miq_groups => [@group])
      snapshot_kid = FactoryBot.create(:snapshot,
                                        :description => 'Snapshot Kid',
                                        :create_time => Time.zone.local(2000, "jan", 1, 20, 15, 1))
      snapshot = FactoryBot.create(:snapshot,
                                    :description => 'Snapshot',
                                    :create_time => Time.zone.local(2000, "jan", 1, 20, 15, 1),
                                    :children    => [snapshot_kid])
      snapshot_kid.parent_id = snapshot.id
      @record = FactoryBot.create(:vm_infra, :snapshots => [snapshot])
      @s_tree = TreeBuilderSnapshots.new(:snapshot_tree, :snapshot, {}, true, :root => @record)
    end
    it 'sets root correctly' do
      root = @s_tree.send(:root_options)
      expect(root).to eq(
        :text       => @record.name,
        :tooltip    => @record.name,
        :icon       => 'pficon pficon-virtual-machine',
        :selectable => false
      )
    end
    it 'returns Snapshot as kids of root' do
      snapshot_nodes = @s_tree.send(:x_get_tree_roots, false)
      snapshot_nodes.each do |snapshot_node|
        expect(snapshot_node).to be_a_kind_of(Snapshot)
      end
    end
    it 'returns Snapshot as kids of Snapshot' do
      snapshot_parent = @s_tree.send(:x_get_tree_roots, false).first
      snapshot_nodes = @s_tree.send(:x_get_tree_snapshot_kids, snapshot_parent, false)
      snapshot_nodes.each do |snapshot_node|
        expect(snapshot_node).to be_a_kind_of(Snapshot)
      end
    end
  end
end
