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

    add_column :events, :fb_id, :string
    add_index :events, :fb_id
    add_column :events, :visibility, :integer, default:2

    Event.find_each do |e|
      if e.friends_only?
        e.visibility = 1
      else
        e.visibility = 2
      end
      e.save
    end

    remove_column :events, :friends_only
    
    User.find_each(:batch_size => 100) do |u|
      u.plans.find_each(:batch_size => 100) do |p|
        unless u.already_invited?(p)
          u.invitations.create!(invited_event_id: p.id)
        end
        u.inmates_and_friends.each(:batch_size => 100) do |f|
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
