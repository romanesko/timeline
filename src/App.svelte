<main>


    {#await checkAuth}
        <p>...waiting</p>
    {:then _}
        {#if $currentUser}
            <Wrapper/>
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
  import Wrapper from "./components/Wrapper.svelte";

  const isTestMode = window.location.hash === "#/test";

  const checkAuth = apiService.init(localStorage.getItem('timeline_token'))

</script>
