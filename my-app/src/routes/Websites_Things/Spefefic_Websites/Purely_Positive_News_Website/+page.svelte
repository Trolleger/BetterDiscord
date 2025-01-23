<script>
    import Page from "../+page.svelte";
</script>

<main>
    <p style="-webkit-text-stroke: 1px white; margin: 0;">
        Purely Positive News!
    </p>

    <button>
        <a href="https://purely-positive-news.blogspot.com/" class="button_top"
            >Link To The Website</a
        >
    </button>
    <p style="font-size: 30px">
        This is a website I made for my school, the idea was given by my teacher
        for the class to work on but nothing ever happened with it ;-; I still
        work on it though, as the title says its pretty clear what this website
        is about its just a bloggish type website with "Purely-Positive-Newsᵀᴹ"
        Well I dont have a trademark on it but pretend I do. For most of the
        articles I just used AI I might work on it seriously some time, but that
        time isn't now really. But maybe you will find a bit of enjoyment from
        this page, make you more positive! But for now I have bigger fish to fry
    </p>
</main>

<footer
    style="background-color: black; text-align: center; padding: 20px; margin: 0; width: 100%;"
>
    What are you doing down here? I guess you noticed how long the page was,
    then scrolled all the way down here, THEN you highlighted this text, good
    job!. Well uh, here is a secret, I know the solution to the P vs NP problem.
    You reverse the verification process. How? I wont tell you but theres a
    clue. If you solve it you will become one ofthe greats in history. But will
    you open a pandoras box with the solution? Do you take the struggle and the
    risk?, I havent but maybe you want to :) Good luck
</footer>

<style>
    main {
        background-image: -webkit-linear-gradient(
            90deg,
            yellow,
            lime,
            royalblue
        );
        height: 8000vh;
        text-align: center;
        font-size: 9rem;
    }

    button {
        /* Variables */
        --button_radius: 10em;
        --button_color: #6495ed;
        --button_outline_color: #000000;
        font-size: 70px;
        font-weight: bold;
        border: none;
        cursor: pointer;
        border-radius: var(--button_radius);
        background: var(--button_outline_color);
    }

    .button_top {
        display: block;
        box-sizing: border-box;
        border: 2px solid var(--button_outline_color);
        border-radius: var(--button_radius);
        padding: 0.75em 1.5em;
        background: var(--button_color);
        color: var(--button_outline_color);
        transform: translateY(-0.2em);
        transition: transform 0.1s ease;
    }

    button:hover .button_top {
        /* Pull the button upwards when hovered */
        transform: translateY(-0.33em);
    }

    button:active .button_top {
        /* Push the button downwards when pressed */
        transform: translateY(0);
    }
</style>
