<script>
  // Any Svelte-specific logic (if needed) can go here
</script>

<style>
  main {
    background-image: linear-gradient(rgb(255, 0, 179), blue);
    height: 100vh;
    overflow-y: auto;
    overflow-x: hidden;
  }

  .slide-right {
    width: 100%;
    position: relative;
    animation: 3s slide-right forwards;
    max-width: 100%;
    padding: 20px;
  }

  .slide-right p {
    color: white;
    font-size: 1em;
    line-height: 1.6;
    word-wrap: break-word;
  }

  @keyframes slide-right {
    from {
      transform: translateX(100%);
    }
    to {
      transform: translateX(0);
    }
  }

  iframe {
    box-shadow: -1px 3px 28px -4px rgba(0, 0, 0, 0.76);
    width: 33.33%;
    height: 400px;
    border-style: inset;
  }

  .iframe-container {
    display: flex;
    justify-content: space-between;
    width: 100%;
    padding: 0;
    margin: 0;
  }
</style>

<main>
  <span>
    <strong>
    <h1 style="font-size: 6em; text-align: center; color: purple; font-family: Consolas, Monaco, monospace; -webkit-text-stroke: 2px black">
      This is my random and conspiracy channel. Enjoy! :p
    </h1>
  </strong>
  </span>

  <a style="font-size: 4.9786em; text-align: center;" href="https://www.youtube.com/@TheTruthIsDeeper">
    A Link To My🤫Random🤫Youtube Channel!
  </a>

  <div class="slide-right">
    <h1 style="font-size: 3em; color: yellow; text-align: center">
      Here are some of my favorite videos! (Information about the channel at bottom), that's all, enjoy! :)
    </h1>

    <div class="iframe-container">
      <iframe src="https://www.youtube.com/embed/33y8WFWBbsM" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/w9IY9-9NkSA" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/NB10bIFdaYk" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
    </div>
    <br>
    <br>

    <p style="font-size: 2em">
      This is my random channel sort of, I just mess around with this channel and put schizo stuff on it. For example I made a video arguing
      with people on the Wynncraft discord server just saying bullshit which I DEFINITELY BELIEVE!!!!! /s/s/s/s/s Point is, I just put random nonsense
      on this youtube channel that does not fit on my gaming youtube channels but you can find some pretty interesting stuff on here :) Might start narrating
      4chan stories or other cool stuff here. This channel is a bit of my playground.
    </p>
  </div>
</main> 