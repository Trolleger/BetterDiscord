<script>
  
</script>
  
<style>

  main {
    background-image: -webkit-linear-gradient(green, purple);
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
    width: 50%; /* Adjust width to 48% to fit two videos side by side */
    height: 400px; /* Ensure the height is set properly */
    border-top-width: 0px;
    border-right-width: 0px;
    border-bottom-width: 0px;
    border-left-width: 0px;
    border-style: inset;
    margin: 0px; /* Add margin to create space between the videos */
  }

  /* Container to hold iframes side by side */
  .iframe-container {
    display: flex;
    flex-wrap: wrap; /* Allow iframes to wrap to the next line on smaller screens */
    justify-content: space-between; /* Distribute the iframes evenly */
  }
</style>

<main>
  <span>
    <h1 style="font-size: 6em; text-align: center; color: white; -webkit-text-stroke: 2px black;">
      This Is My Variety gaming Channel
    </h1>
  </span>

  <a style="font-size: 4.783em; text-align: center; -webkit-text-stroke: 2px royalblue;" href="https://www.youtube.com/@CK_Trolleger">
    A Link To My Variety Gaming Youtube Channel!
  </a>

  <div class="slide-right">

    <h1 style="font-weight: bold; font-size: 3em; -webkit-text-stroke: 0.3px white; color: #1E90FF; text-shadow: #32CD32 1px 0 80px; text-align: center;">
      Lower down you can find some of my videos and more information about the channel :)
    </h1>

    
  
      <h1 style="font-size: 4em; color: black; text-align: center; text-shadow: 0 0 10px red, 0 0 20px blue, 0 0 30px purple, 0 0 40px green;">
        Here are some of my videos!
      </h1>
      

    <!-- YouTube Video Embed with Simple Title Attribute -->
    <div class="iframe-container">
      <iframe src="https://www.youtube.com/embed/yzYJY6y1Ndc" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/7cXWEHw_4FE" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/jt5KchRUmfc" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/SJm-GXGPtM4" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/wOfg8y4tf_U" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/9pl5ciVMSm0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/-TO6R3Wi5Hc" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
      <iframe src="https://www.youtube.com/embed/H3yDYBFVoeM" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen title="YouTube Video"></iframe>
    </div>

    <p style="font-size: 2em">
     This is my variety gaming channel, unlike my first channel I have other games and game related content. However in the future I may post lower edited minecraft content on there which might not do the best in the algorithim and in viewers reception l but I still like and will post not on the main channel
     <br>
     So beyond just having other minecraft junk I have on here just a bunch of random games I play with myself and friends. I have a lot of videos always ready to be edited. So I hope I will always add videos onto this channel, its just more experimental gaming maybe youknow?
     <br>
     So if you are interested in seeing me play other games other else then minecraft and less highly edited and professional videos then chess this out :p Take Care!
    </p>

  </div>
</main>
