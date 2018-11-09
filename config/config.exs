# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :forthwith_ex, :ttyACM0,
  name: "ttyACM0",
  speed: 115_200,
  active: true,
  rx_framing_timeout: 50

config :forthwith_ex,
  uarts: [:ttyACM0],
  special_commands_mfa: nil

config :logger, backends: [:console]

# app_dir = Application.app_dir(:forthwith_ex)
# priv_dir = Path.join([app_dir, "priv"])

config :iex_ssh_shell,
  system_dir: "./priv/ssh",
  port: 4444,
  handler: Elixir.ForthWithEx.ShellHandler.Default,
  sepcial_commands_handler: nil,
  authorized_keys: [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9ivahynnMTgy/7z3UPzL+/nYRs3rocn/Y8B5h48Z28VsntBej8yQr7EC69XQS+yEgp0zhww6BgspzjFuA7AWqOkUq6mGHsDAt2tIEs9Ip+mpF6buHxmMnNldKottLoTAHBkfO7Uv8z8uiFAKYrwY9bCA1L8TIPJ2hTAHFPvxcVxL7t0I2fHpqpGenP8MVX28U4HP8Z/WOP+AR7LeuVSqOz8FQ25UVInHvbc+RHtNcWfeHo7SsPdaJ4ykRMBb3zfm3pQs/KFRYAHi8SPcWonHq3KvvOOtV5mgw7VcRqPJp0qiyVMlVtpHsTcnbnDrRAmb/p6ZFiLq2catwT+A6I7c0/wQIKTfQ4Ed6Z2JRp3+yqRBk9kJboO7K8f+CFACk7m/bF6d7PX250vWhUGXshEcVI0URiycTN0ulYWPm5hAS2GDuCSEOj/8nrn2vqYbuUUZ4FqrXYslhwLin8DvsvSo/QMho2t3imi2GQK8ZquChYla5Lq1aN56vIE/5Q7Vz15KX8n2y0CGyxmEyYW1V17OC0rzV+VjnOO2DN4npRoyY08i6CoRY1tCOBcOl5HofDriAylHVHJNgTcGXkipwqH9kzd3rjZHe846rqklLwmD8vU+BXVqcjNBHSNAWXxMVe+tDN+hp6qK1MCadIQSf/db5vcIakPPbl5QPqE/gAdHDSw== iot@prongtech.com"
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
