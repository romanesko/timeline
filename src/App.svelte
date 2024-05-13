<main>

    {#if !isTestMode}
        <Wrapper/>
    {:else}

        {#await checkAuth}
            <p>...waiting</p>
        {:then _}
            {#if $currentUser}
                <Timeline/>
            {:else}
                <Auth/>
            {/if}

        {:catch error}
            <p style="color: red">{error.message}</p>
        {/await}
    {/if}
</main>

<script>
  import {apiService} from "./lib/api";
  import Auth from "./components/Auth.svelte";
  import {currentUser} from "./lib/MainStore.js";
  import Timeline from "./components/Timeline.svelte";
  import CanvasTimeline from "./components/CanvasTimeline.svelte";
  import Wrapper from "./components/Wrapper.svelte";

  const isTestMode = window.location.hash === "#/test";

  const checkAuth = apiService.init(localStorage.getItem('timeline_token'))

</script>
