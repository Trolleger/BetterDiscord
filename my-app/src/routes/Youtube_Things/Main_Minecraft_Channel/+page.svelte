<script>
  // Your script logic goes here, if needed for further functionality
  </script>
  
  <style>
    main {
      background-image: -webkit-linear-gradient(black, blue);
      height: 100vh; /* Ensure the main element takes up the full height of the viewport */
      overflow-y: auto; /* Allow vertical scrolling */
      overflow-x: hidden; /* Prevent horizontal overflow */
    }
  
    .slide-right {
      width: 100%;
      position: relative; /* Enable relative positioning for proper animation */
      animation: 3s slide-right forwards; /* Removed the 1s delay to start the animation immediately */
      max-width: 90%; /* Increased to 90% of the screen width */
      margin: 0 auto; /* Center the content horizontally */
      padding: 20px; /* Add some padding for spacing */
    }
  
    .slide-right p {
      color: white;
      font-size: 1em;
      line-height: 1.6; /* Make the text more readable */
      word-wrap: break-word; /* Ensure long words break and wrap properly */
    }
  
    @keyframes slide-right {
      from {
        transform: translateX(100%); /* Start from the far right (100% off-screen) */
      }
      to {
        transform: translateX(0); /* Move to the normal position (centered) */
      }
    }
  
    iframe {
      box-shadow: -1px 3px 28px -4px rgba(0, 0, 0, 0.76);
      width: 50%;
      height: 400px; /* Ensure the height is set properly */
      border-top-width: 0px;
      border-right-width: 0px;
      border-bottom-width: 0px;
      border-left-width: 0px;
      border-style: inset;
    }
  </style>
  
  <main>
    <span>
      <h1 style="font-size: 6em; text-align: center; color: maroon; font-family: Consolas, Monaco, monospace;">
        This is my Minecraft Channel
      </h1>
    </span>
  
    <a style="font-size: 5.446em; text-align: center;" href="https://www.youtube.com/@Trolleger">
      A Link To My Minecraft Youtube Channel!
    </a>
  
    <div class="slide-right">
      <p>
        Well, this was my first and main channel. (EVERYTHING IS MINECRAFT RELATED) Before it, I had another YouTube channel, but I unfortunately lost the Gmail to it randomly one day because Google felt like they wanted to lock me out for "security purposes." But that's besides the point, originally this was my channel for some random content I posted, be it roams.io/bettermope.io/mohio or whatever you call it now, Roblox, memes, etc. But I decided to do Minecraft for a change.
        <br><br>
        But my first videos did horribly, then the next, then the next, but I kept on persevering and I finally started getting into the hundreds of views! I started posting shorts and unlisted all the irrelevant content on my YouTube channel. And today, I am doing very well working on new videos and stuff! As always, this is a Minecraft-first YouTube channel, so everything is Minecraft-related. So that's where I am right now. I'll report back when I get 1000 subscribers, but I have many great videos along the way :)
      </p>
  
      <p>Well I might as well, here are some of my more recent videos which I would say are pretty nice</p>
  
      <!-- YouTube Video Embed with Simple Title Attribute -->
      <div>
        <iframe src="https://www.youtube.com/embed/lbNd56k5qYw" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
        <iframe src="https://www.youtube.com/embed/iAX53RlSxzY" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
        <iframe src="https://www.youtube.com/embed/fyUwlPRYREg" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
        <iframe src="https://www.youtube.com/embed/tppXzG1Bfnk" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
        <iframe src="https://www.youtube.com/embed/uICefwuHpM8" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
        <iframe src="https://www.youtube.com/embed/YlRIWUz40LA" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      </div>
    </div>
  </main>
  