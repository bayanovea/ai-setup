---
worth: yes
added: 2026-10-29
---
# import YouTube subscriptions as RSS feeds into the my-interests profile

The digest reads YouTube through channel RSS feeds
(`https://www.youtube.com/feeds/videos.xml?channel_id=<id>`), and the profile has none yet, so the
video half of the morning digest relies on web search. Export subscriptions (Google Takeout,
YouTube → `subscriptions.csv` with channel ids), keep the channels worth following, and ask Hermes to
add them to `my-interests/references/profile.md` with their feed URLs.
