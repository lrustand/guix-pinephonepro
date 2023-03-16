(define-module (config)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages linux)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (nonguix licenses))

(define pinephone-pro-firmware
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
    "https://github.com/megous/linux/archive/refs/tags/" version ".tar.gz")))

(define* (linux-pinephone-pro
          version
          hash
          #:key
          (name "linux-pinephone-pro")
          (linux linux-libre-arm64-generic))
  (package
    (inherit
     (customize-linux
      #:name name
      #:linux linux
      #:defconfig
      ;; "pinephone_pro_defconfig"
      ;; TODO: Rewrite it to the simple patch for the source code
      (local-file "./src/pinephone_pro_defconfig")
      #:extra-version "arm64-pinephone-pro"
      #:source (origin (method url-fetch)
                       (uri (linux-pinephone-urls version))
                       (sha256 (base32 hash)))))
    (version version)
    (home-page "https://www.kernel.org/")
    (synopsis "Linux kernel with nonfree binary blobs included")
    (description
     "The unmodified Linux kernel, including nonfree blobs, for running Guix
System on hardware which requires nonfree software to function.")))

(define-public pinephone-pro-kernel
  (linux-pinephone-pro "orange-pi-6.3-20230313-0715"
                       "1hildn23b83r2r47jxp3xgy797q70sqabmliil7scrv91ay3hcr2"))
