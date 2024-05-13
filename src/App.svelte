<main>

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
</main>

<script>
  import {apiService} from "./lib/api";
  import Auth from "./components/Auth.svelte";
  import {currentUser} from "./lib/MainStore.js";
  import Timeline from "./components/Timeline.svelte";

  const checkAuth = apiService.init(localStorage.getItem('timeline_token'))

</script>
