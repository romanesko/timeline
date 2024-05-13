<div class="flex items-center  min-h-screen">
    <div class="flex flex-col justify-items-start min-w-96">

        {#if DEMO_MODE}

            <Alert border class="mb-6">
                <div class="font-medium">This is a demo mode</div>
                <p class="text-sm my-1">
                    Login details are provided in the login form. </p>
                <p class="text-sm">
                    Just press the <code>Login</code> button. </p>
            </Alert>
        {/if}

        {#if error}
            <Alert border class="mb-6">
                <span class="font-medium">{error}</span>

            </Alert>
        {/if}

        <div class="mb-6">
            <Label class="block mb-2" for="default-input">Login</Label>
            <Input bind:value={form.login} id="login" placeholder="Login"/>
        </div>

        <div class="mb-6">
            <Label class="block mb-2" for="default-input">Password</Label>
            <Input bind:value={form.password} id="password" placeholder="Password" type="password"/>

        </div>

        <div class="flex justify-center">
            <Button class="flex-grow" on:click={handleLoginClick} type="submit">Login</Button>
        </div>

        <div class="min-h-96"></div>


    </div>
</div>
<script>
  import {Alert, Button, Input, Label} from "flowbite-svelte";
  import {apiService} from "../lib/api";
  import {currentUser} from "../lib/MainStore.js";


  let error = ''

  const DEMO_MODE = window['DEMO_MODE']

  const form = {login: DEMO_MODE ? 'demo' : undefined, password: DEMO_MODE ? 'demo' : undefined}


  async function handleLoginClick() {
    try {
      const res = await apiService.auth({login: form.login, password: form.password})

    } catch (e) {
      error = e.message
    }
  }


</script>
