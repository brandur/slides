slides
======

An extremely simplistic logs-as-events implementation.

``` ruby
Slides.log(:app_created, app_id: @app.id, user_id: @user.id)

=> app_created app_id=456 user_id=23
```

``` ruby
app_id = nil
Slides.log(:app_create, app_id: -> { app_id }, user_id: @user.id) do
  app_id = AppCreator.new.run.id
end

=> app_create user_id=23 at=start
=> app_create app_id=456 user_id=23 at=finish elapsed=5ms
```

Testing
-------

    rake test
