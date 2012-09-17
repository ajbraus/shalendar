web: bundle exec rails server thin -p $PORT -e $RACK_ENV

resque: VVerbose=1 env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 QUEUES=email_queue,apple_push_notifications bundle exec rake jobs:work
