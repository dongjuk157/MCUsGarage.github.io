            "sharing": {
                "facebook": false,

                "google": false,

                "github": true,
              {% if site.github_username %}
                "github_link": "https://github.com/MCUsGarage",
              {% else %}
                "github_link": "https://github.com/MCUsGarage",
              {% endif %}

                "telegram": false,
                "telegram_link": "https://t.me",

                "instapaper": false,

                "twitter": false,
              {% if site.twitter_username %}
                "twitter_link": "https://twitter.com/{{ site.twitter_username }}",
              {% endif %}

                "vk": false,

                "weibo": false,

                "all": ["github"]
            },
