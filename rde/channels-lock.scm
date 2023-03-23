(use-modules (guix channels))

(list (channel
        (name 'non-guix)
        (url "https://gitlab.com/nonguix/nonguix")
        (branch "master")
        (commit
          "2dde2a60067ee383b753b85d608a7c20ff315634")
        (introduction
          (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
              "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
        (name 'guix)
        (url "https://git.savannah.gnu.org/git/guix.git")
        (branch "master")
        (commit
          "1ed227d7952af48efe50a2f6c9537e17c356daa1")
        (introduction
          (make-channel-introduction
            "9edb3f66fd807b096b48283debdcddccfea34bad"
            (openpgp-fingerprint
              "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
