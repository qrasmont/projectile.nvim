## projectile.nvim

Plugin for projectile.

![](_resources/demo.gif)

### Config

Sample config with default values:
```lua
require('projectile').setup{
    output_behavior = 'notify',
    notifier = {
        wait = {
            wait_text = 'Projectile',
            rate = 1000,
        },
        done = {
            success_symbol = '✔',
            success_text = 'Success',
            fail_symbol = '✖',
            fail_text = 'Fail',
            delay = 3000,
        }
    }
}
```

#### output_behavior
- "notify"
- "on_exit"
- "on_stdout"
