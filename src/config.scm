(define-module (config)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages linux)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (nonguix licenses))

(define-public pinephone-pro-firmware
  (let ((commit "5c4c2b89f30a42f5ffabb5b5bcbc799d8ac9f66f")
        (revision "1"))
    (package
      (name "pinephone-pro-firmware")
      (version (git-version "0.0.0" revision commit))
      (home-page "https://megous.com/git/linux-firmware")
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url home-page)
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "0210dpxhb257zwncv5r1qiq7rlyiy1c14mx9vscnsv6rggf1id9w"))))
      (build-system copy-build-system)
      (arguments
       `(#:install-plan
         (list
          (list "anx7688-fw.bin" "lib/firmware/")
          (list "hm5065-af.bin" "lib/firmware/")
          (list "hm5065-init.bin" "lib/firmware/")
          (list "ov5640_af.bin" "lib/firmware/")
          (list "regulatory.db" "lib/firmware/")
          (list "regulatory.db.p7s" "lib/firmware/")
          (list "rockchip" "lib/firmware/")
          (list "rt2870.bin" "lib/firmware/")
          (list "rtl_bt" "lib/firmware/")
          (list "rtlwifi" "lib/firmware/")
          (list "rtw88" "lib/firmware/")
          (list "rtw89" "lib/firmware/")
          (list "brcm" "lib/firmware/"))))
      (synopsis "Nonfree Linux firmware blobs for PinePhone Pro")
      (description "Nonfree Linux firmware blobs for PinePhone Pro.")
      (license
       (nonfree
        (string-append "https://git.kernel.org/pub/scm/linux/kernel/git/"
                       "firmware/linux-firmware.git/plain/WHENCE"))))))

(define (linux-pinephone-urls version)
  "Return a list of URLS for Linux VERSION."
  (list
   (string-append
    "https://codeberg.org/megi/linux/archive/" version ".tar.gz")))

(define* (linux-pinephone-pro
          version
          hash
          #:key
          (name "linux-pinephone-pro")
          (linux linux-libre-arm64-generic))
  (let ((linux-package
         (customize-linux
          #:name name
          #:linux linux
          #:defconfig
          ;; It could be "pinephone_pro_defconfig", but with a small patch
          ;; TODO: Rewrite it to the simple patch for the source code
          (local-file "./pinephone_pro_defconfig")
          #:extra-version "arm64-pinephone-pro"
          #:source (origin (method url-fetch)
                           (uri (linux-pinephone-urls version))
                           (sha256 (base32 hash))))))
    (package
     (inherit linux-package)
     (version version)
     (inputs (list pinephone-pro-firmware))
     (arguments
      (substitute-keyword-arguments (package-arguments linux-package)
        ((#:phases phases '%standard-phases)
         #~(modify-phases
            #$phases
            (add-after 'configure 'set-firmware-path
               (lambda _
                 (copy-recursively
                  (assoc-ref %build-inputs "pinephone-pro-firmware") "ppp")
                 (format #t "====>")
                 (system "cat .config")
                 (format #t "====>")))))))
     (home-page "https://www.kernel.org/")
     (synopsis "Linux kernel with nonfree binary blobs included")
     (description
      "The unmodified Linux kernel, including nonfree blobs, for running Guix
System on hardware which requires nonfree software to function."))))

(define-public pinephone-pro-kernel
  (linux-pinephone-pro "orange-pi-6.3-20230313-0715"
                       "1x5ijg2ycf0bhlma52k7glw5pmr78gyxcr16x7ywd5k5cb3wvc1g"))

(use-modules (gnu system)
             (gnu system keyboard)
             (gnu system file-systems)
             (gnu system shadow)
             (gnu bootloader)
             (gnu bootloader u-boot)
             (gnu services)
             (gnu services base)
             (gnu services dbus)
             (gnu services ssh)
             (ice-9 match)
             (srfi srfi-1)
             (gnu packages base)
             (gnu packages bash)
             (gnu packages fonts))

(use-modules (gnu services networking)
             (rde system services networking)
             (gnu packages gnome))

(define %my-services
  (append
   %base-services
   (list
    (service iwd-service-type
             (iwd-configuration
              (main-conf
               `((Settings ((AutoConnect . #t)))))))
    (service openssh-service-type
             (openssh-configuration
              (x11-forwarding? #f)
              (permit-root-login #f)
              (allow-empty-passwords? #f)
              (password-authentication? #f)
              (public-key-authentication? #t)
              (allow-agent-forwarding? #t)
              (allow-tcp-forwarding? #t)
              (gateway-ports? #f)
              (challenge-response-authentication? #f)
              (use-pam? #t)
              (authorized-keys
               `(("bob" ,(local-file "../files/ssh.key"))))
              (print-last-log? #t))))))

(define pinephone-pro-os
  (operating-system
    (kernel pinephone-pro-kernel)
    (kernel-arguments
     (append
      (list
       "console=ttyS2,115200"
       "earlycon=uart8250,mmio32,0xff1a0000"
       "earlyprintk")
      (drop-right %default-kernel-arguments 1)))

    (initrd-modules '())

    (firmware (append
               (list pinephone-pro-firmware)
               %base-firmware))
    (host-name "pinephonepro")
    (timezone "Europe/Istanbul")
    (locale "en_US.utf8")
    (keyboard-layout (keyboard-layout "us" "dvorak"))

    (bootloader
     (bootloader-configuration
      (bootloader u-boot-rockpro64-rk3399-bootloader)
      (targets '("/dev/mmcblk0p1"))))

    (file-systems
     (cons
      (file-system
        (device "/dev/mmcblk0p2")
        (mount-point "/")
        (type "ext4"))
      %base-file-systems))

    (users (cons (user-account
                  (name "bob")
                  (password (crypt "3412" "$6$abc"))
                  (group "users")
                  (supplementary-groups '("wheel" "audio" "video"))
                  (home-directory "/home/bob"))
                 %base-user-accounts))

    (packages
     (append (list nss-certs)
      %base-packages))

    (services %my-services)))

pinephone-pro-os
