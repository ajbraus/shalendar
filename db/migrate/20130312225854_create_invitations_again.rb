class CreateInvitationsAgain < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :invited_user_id
      t.integer :invited_event_id

      t.timestamps
    end

    add_index :invitations, :invited_user_id
    add_index :invitations, :invited_event_id
    add_index :invitations, [:invited_user_id, :invited_event_id], unique: true

    User.all.each do |u|
      u.plans.each do |p|
        unless u.already_invited?(p)
          u.invitations.create!(invited_event_id: p.id)
        end
        u.inmates_and_friends.each do |f|
          if p.friends_only?
            if u.is_friends_with?(f)
              unless f.already_invited?(p)
                f.invitations.create!(invited_event_id: p.id)
              end
            end
          else
            unless f.already_invited?(p)
              f.invitations.create!(invited_event_id: p.id)
            end
          end
        end
      end
    end

  end
end
