---
title: "Oh my God, they killed Kenny!"
tags:
- Nushell
- South Park
- Streaming
- Web Parsing
date: 2022-08-02T09:26:51+05:30
draft: false
---

# Introduction

Despite its infamy for profanity and dark, satiric humor, I've been a huge fan of South Park over the years. I'd like you to try out a random episode of [South Park](https://www.southparkstudios.com).
Before you walk away saying, ["Screw you guys, I'm going home"](https://www.youtube.com/watch?v=RXS1sJm7QEA), I'll be sharing a little trick to watch a random episode without even launching the browser.

### Prerequisites:
- [Nushell](https://www.nushell.sh)
- [mpv](https://mpv.io)
- `youtube-dl` or [yt-dlp](https://github.com/yt-dlp/yt-dlp)

# Gone scripting

South Park's official website has a route called `random-episode` which redirects us to, well, a random episode.
The redirection, however, is done using javascript instead of regular HTTP status codes like 302.
This meant, one couldn't simply run the following and expect to see a video.
```sh
mpv https://southparkstudios.com/random-episode
```

Let's try being a little creative to see what the page returns.

```sh
http get https://southparkstudios.com/random-episode
```

Along the response lines, we can observe javascript assigning to `window.__DATA__` that contains paths to many random episodes.

```js
window.__DATA__ = {"type":"Page","props":{"bentoURL":"https:\u002F\u002Fbtg.mtvnservices.com\u002Faria\u002Fbentojs.js?site=webplex-southpark-intl&v=3.2.0","edenData":null,"imageConfig":null,"authSuiteConfig":{"authSuiteEnv":{"adobeUrl":"https:\u002F\u002Fapi.auth.adobe.com","authSuiteUrl":"https:\u002F\u002Fauth.mtvnservices.com","isisUrl":"https:\u002F\u002Fmusicjsonpath-a.akamaihd.net","tveUrl":"https:\u002F\u002Ftve.mtvnservices.com","xboxUrl":"https:\u002F\u002Fxbox.mtvnservices.com"}},"featureFlags":{"test1":true,"test2":true,"isContinueWatchingEnabled":true,"isPublicShowPagesEnabled":true,"isCompositeUserSelectionEnabled":true,"isUserWatchlistEnabled":true},"edenConfig":null,"helmet":{"helmet":{"base":{},"bodyAttributes":{},"htmlAttributes":{},"link":{},"meta":{},"noscript":{},"script":{},"style":{},"title":{}}}},"children":[{"type":"MainContainer","children":[{"type":"RandomEpisodeQueue","props":{"items":{"items":[{"shortId":"1nq9xv","path":"\u002Fepisodes\u002F1nq9xv\u002Fsouth-park-broadway-bro-down-season-15-ep-11"},{"shortId":"rxb67x","path":"\u002Fepisodes\u002Frxb67x\u002Fsouth-park-the-entity-season-5-ep-11"},{"shortId":"u1yv8w","path":"\u002Fepisodes\u002Fu1yv8w\u002Fsouth-park-canada-on-strike-season-12-ep-4"},{"shortId":"2b4m4s","path":"\u002Fepisodes\u002F2b4m4s\u002Fsouth-park-ass-burgers-season-15-ep-8"},{"shortId":"uvp08l","path":"\u002Fepisodes\u002Fuvp08l\u002Fsouth-park-ginger-kids-season-9-ep-11"},{"shortId":"aba4sz","path":"\u002Fepisodes\u002Faba4sz\u002Fsouth-park-freak-strike-season-6-ep-3"},{"shortId":"hmaufp","path":"\u002Fepisodes\u002Fhmaufp\u002Fsouth-park-poor-and-stupid-season-14-ep-8"},{"shortId":"u9u3rq","path":"\u002Fepisodes\u002Fu9u3rq\u002Fsouth-park-butt-out-season-7-ep-13"},{"shortId":"97d61n","path":"\u002Fepisodes\u002F97d61n\u002Fsouth-park-succubus-season-3-ep-3"},{"shortId":"oki0th","path":"\u002Fepisodes\u002Foki0th\u002Fsouth-park-pinewood-derby-season-13-ep-6"},{"shortId":"z31od5","path":"\u002Fepisodes\u002Fz31od5\u002Fsouth-park-preschool-season-8-ep-10"},{"shortId":"81p0af","path":"\u002Fepisodes\u002F81p0af\u002Fsouth-park-dances-with-smurfs-season-13-ep-13"},{"shortId":"qly8oc","path":"\u002Fepisodes\u002Fqly8oc\u002Fsouth-park-a-ladder-to-heaven-season-6-ep-12"},{"shortId":"5fuujn","path":"\u002Fepisodes\u002F5fuujn\u002Fsouth-park-trapper-keeper-season-4-ep-12"},{"shortId":"me0b40","path":"\u002Fepisodes\u002Fme0b40\u002Fsouth-park-casa-bonita-season-7-ep-11"},{"shortId":"avmdp8","path":"\u002Fepisodes\u002Favmdp8\u002Fsouth-park-coon-vs-coon-friends-season-14-ep-13"},{"shortId":"327ba3","path":"\u002Fepisodes\u002F327ba3\u002Fsouth-park-eek-a-penis-season-12-ep-5"},{"shortId":"xenush","path":"\u002Fepisodes\u002Fxenush\u002Fsouth-park-pee-season-13-ep-14"},{"shortId":"scexjh","path":"\u002Fepisodes\u002Fscexjh\u002Fsouth-park-starvin-marvin-season-1-ep-8"},{"shortId":"9do3gw","path":"\u002Fepisodes\u002F9do3gw\u002Fsouth-park-margaritaville-season-13-ep-3"},{"shortId":"n9jsjf","path":"\u002Fepisodes\u002Fn9jsjf\u002Fsouth-park-tonsil-trouble-season-12-ep-1"},{"shortId":"44i3y3","path":"\u002Fepisodes\u002F44i3y3\u002Fsouth-park-tom-s-rhinoplasty-season-1-ep-11"},{"shortId":"1jbnuo","path":"\u002Fepisodes\u002F1jbnuo\u002Fsouth-park-lil-crime-stoppers-season-7-ep-6"},{"shortId":"dumjvr","path":"\u002Fepisodes\u002Fdumjvr\u002Fsouth-park-cartman-s-mom-is-a-dirty-slut-season-1-ep-13"},{"shortId":"ex6roo","path":"\u002Fepisodes\u002Fex6roo\u002Fsouth-park-a-history-channel-thanksgiving-season-15-ep-13"},{"shortId":"06brb8","path":"\u002Fepisodes\u002F06brb8\u002Fsouth-park-probably-season-4-ep-10"},{"shortId":"t746u2","path":"\u002Fepisodes\u002Ft746u2\u002Fsouth-park-proper-condom-use-season-5-ep-7"},{"shortId":"d7grkc","path":"\u002Fepisodes\u002Fd7grkc\u002Fsouth-park-the-passion-of-the-jew-season-8-ep-3"},{"shortId":"7efemk","path":"\u002Fepisodes\u002F7efemk\u002Fsouth-park-tweek-vs-craig-season-3-ep-5"},{"shortId":"akix98","path":"\u002Fepisodes\u002Fakix98\u002Fsouth-park-pandemic-2-the-startling-season-12-ep-11"},{"shortId":"x5mqiz","path":"\u002Fepisodes\u002Fx5mqiz\u002Fsouth-park-medicinal-fried-chicken-season-14-ep-3"},{"shortId":"ppnf3g","path":"\u002Fepisodes\u002Fppnf3g\u002Fsouth-park-truth-and-advertising-season-19-ep-9"},{"shortId":"iyw8ps","path":"\u002Fepisodes\u002Fiyw8ps\u002Fsouth-park-cartman-finds-love-season-16-ep-7"},{"shortId":"y3uvvc","path":"\u002Fepisodes\u002Fy3uvvc\u002Fsouth-park-grounded-vindaloop-season-18-ep-7"},{"shortId":"38exov","path":"\u002Fepisodes\u002F38exov\u002Fsouth-park-the-problem-with-a-poo-season-22-ep-3"},{"shortId":"c5x1x5","path":"\u002Fepisodes\u002Fc5x1x5\u002Fsouth-park-the-scoots-season-22-ep-5"},{"shortId":"xj9ctz","path":"\u002Fepisodes\u002Fxj9ctz\u002Fsouth-park-buddha-box-season-22-ep-8"},{"shortId":"hjfzgc","path":"\u002Fepisodes\u002Fhjfzgc\u002Fsouth-park-a-boy-and-a-priest-season-22-ep-2"},{"shortId":"5b6ld6","path":"\u002Fepisodes\u002F5b6ld6\u002Fsouth-park-tegridy-farms-season-22-ep-4"},{"shortId":"ykf57h","path":"\u002Fepisodes\u002Fykf57h\u002Fsouth-park-dead-kids-season-22-ep-1"}],"storageNamePrefix":"default"}}}]}]};
```

We can now grab the video's short identifier (`shortId`) and format the URL to the specific episode.
To do this, we can use Nu's `parse` command which allows regular expression matches.

```sh
http get https://southpark.cc.com/random-episode | parse -r '"shortId":"(.+?)"' | first 5 
```

This gives us the following table:

_#_| capture0
---|---------
 0 | dfdwfl
 1 | oq0xia   
 2 | 2bf9a5   
 3 | jy5lbq
 4 | 4sa1hk

Since these are random episodes, we can do away with picking the first captured ID.

```sh
(http get https://southpark.cc.com/random-episode | parse -r '"shortId":"(.+?)"').capture0.0 
```

```
wpmnpk
```

All we are left with now is to append this to the episodes URL path and pass it to `mpv`.
We will use the `$"string"` syntax to interpolate the short ID into the URL.

```sh
mpv $"https://southpark.cc.com/episodes/((http get https://southpark.cc.com/random-episode | parse -r '"shortId":"(.+?)"').capture0.0)"
```
