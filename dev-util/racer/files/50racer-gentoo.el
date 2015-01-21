(add-to-list 'load-path "@SITELISP@")
(setq racer-cmd "/usr/bin/racer")
(eval-after-load "rust-mode" '(require 'racer))
