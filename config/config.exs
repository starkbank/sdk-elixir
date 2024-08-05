import Config
private_key_content = """
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIMshmWWvbnePdooqhQMT2670ZZlATrcza0lbtgBsY2K/oAcGBSuBBAAK
oUQDQgAEfEtQ9B/RpSB4+Pl5WoKi374kB3xAICPLpXDjyadX5BOwCZcg6qiI9skL
Y/JUQkznW0+wv1ylC4CgLs9YZuFH7Q==
-----END EC PRIVATE KEY-----
"""

config :starkbank,
  language: "en-US",
  project: [
    environment: :sandbox,
    id: "4835910956875776",
    private_key: private_key_content
  ]
