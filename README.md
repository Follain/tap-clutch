tap-clutch
==========

## A [singer.io](http://singer.io) tap to extract data from [Clutch](http://clutch.com) and load into any Singer target, like Stitch or CSV

# Configuration

    {
      "api_key": "api_key",
      "api_secret": "secret",
      "api_base": "https://api.clutch.com/merchant/",
      "brand": "clutch_brand",
      "location": "clutch_location",
      "card_set_id": "clutch_card_set_id",
      "terminal": "clutch_terminal",
      "username": "clutch_portal_user_id",
      "password": "clutch_portal_password"
    }

# Usage (with [Stitch target](https://github.com/singer-io/target-stitch))

    > bundle exec tap-clutch
    Usage: tap-clutch [options]
        -c, --config config_file         Set config file (json)
        -s, --state state_file           Set state file (json)
        -h, --help                       Displays help
        -v, --verbose                    Enables verbose logging to STDERR

    > pip install target-stitch
    > gem install tap-clutch
    > bundle exec tap-clutch -c config.clutch.json -s state.json | target-stitch --config config.stitch.json | tail -1 > state.new.json
