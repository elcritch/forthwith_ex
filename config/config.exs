# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :forthwith_ex, :ttyACM0,
  name: "ttyACM0",
  speed: 115_200,
  active: true,
  rx_framing_timeout: 50

config :forthwith_ex, uarts: [:ttyACM0]

config :logger, backends: [:console]

# app_dir = Application.app_dir(:forthwith_ex)
# priv_dir = Path.join([app_dir, "priv"])

config :iex_ssh_shell,
  system_dir: "./priv/ssh",
  port: 4444,
  handler: Elixir.ForthWithEx.ShellHandler.Example,
  authorized_keys: [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNnURXeZ846e2KLM6IEePF8U5F5C58bDMdCCWdlJi189ISKUsfA8i9GIm+2y2H0PAYL2NrW3Ey+9cfALMLIGQGDeWpLWd/VkNr/eAVJ/8mEreNeRbWYfLHWRIfk4qLWt5fXlkfiEywLYetZBJXdoa9F/2NlMZX1kbKNEVQD0gREaQaOnRNSimHDPzMficiJcdlFT1Jdu+cxjleto0rEwiBJhWf5EygTlDaB5PN1CLt7b2tBhmyfHPw4etBGfAvL8Dyl0a+xVh64YEyO7LfXyDQOXJaidtcH3Abc/N4IiJXHSqxipqao64Tzi9mgTn6D84DatuOYfabSl3WLDGHJSka5LIPU+y36YovpgeKvYVTU4O/2kyBoSd8kaTL6uXD0oSCnrEHThHLTcrSzuCjMIM1dCXN+G6bhW47chOEHfw3G0ZnY/SyR/7S5xQ0FZwJf0ub++Scf//yaOECMViAn+1T/qBsJNMKeRcv3fPFeMdkO8mWD+qpHaJD1nmVvZD+UVhqmTou5WhKFiIqc3v1+WZ7SXIlWqIchWsje84LOqeLyylnyKYqkVKGDIHOLAWR5WEgPXtKm0hfBwPqlfit12vuqLpYL1Er3o+E45Hb1b6VHyt/Yo86A3XlQ1V1ETkJMXWAeRM1Ne5OQuKG9jyP/p+rvbn04kqjY+LPeysSgr9KrQ== creechley@gmail.com "
  ]

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :forthwith_ex, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:forthwith_ex, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
