object @event
attributes :id, :title, :description
child(:creator) { attributes :name }