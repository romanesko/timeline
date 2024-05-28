<div class="flex flex-col gap-1 px-4">
    <Toast bind:open={savedToast} class="absolute top-0 left-0 m-4" color="green" dismissable={true} transition={slide}>
        <svelte:fragment slot="icon">✓</svelte:fragment>
        Настройки успешно сохранены
    </Toast>
    {#if _zone}
        <Input bind:value={_zone.label} name="zoneLabel" placeholder="Название" required size="md" type="text"/>

        <div class="flex items-center justify-start gap-2 mt-4 mb-2">
            <div>Типы слотов</div>
            <Button size="xs" class="py-1" color="primary" on:click={handleTypeAddClick} outline>добавить</Button>
        </div>
        <div class="flex flex-col gap-2">
            {#each types as type}
                <div class="flex gap-2 items-center" class:hidden-value={type.label.startsWith('_')}>
                    {type.id}
                    <Input bind:value={type.label} name="typeLabel" placeholder="Название" required size="md" type="text"/>
                    <input bind:value={type.color} name="typeColorColor" placeholder="Цвет" required type="color" class="color-picker"/>
                </div>
            {/each}


        </div>
        <div class="flex items-center justify-start gap-2 mt-4 mb-2">
            <div>Тренеры</div>
            <Button size="xs" class="py-1" color="primary" on:click={handleTagAddClick} outline>добавить</Button>
        </div>

        <div class="flex flex-col gap-2">
            {#each tags as tag}
                <div class="flex gap-2 items-center" class:hidden-value={tag.label.startsWith('_')}>
                    {tag.id}
                    <Input bind:value={tag.label} name="tagLabel" placeholder="Название" required size="md" type="text"/>
                </div>
            {/each}
        </div>

        <div class="text-xs text-gray-500 mt-4 text-center">
            чтобы скрыть элемент, начните его имя с символа подчёркивания
        </div>
        <div class="text-center mt-4">
            <Button class="me-2" color="red" on:click={handleSaveSettingsClick}>Сохранить</Button>
        </div>
    {/if}
</div>

<script>
  import {Button, Input, Toast} from "flowbite-svelte";
  import {apiService} from "../lib/api.js";
  import {createEventDispatcher} from "svelte";
  import {slide} from "svelte/transition";

  let savedToast = false;

  export let zone;
  let _zone = {id: undefined};
  let types = [];
  let tags = [];

  const emit = createEventDispatcher();

  $: if (zone && zone.id && _zone.id !== zone.id) {
    _zone = zone;
    types = zone.types.map((type) => {
      if (type.color.indexOf("rgb") > -1) {
        type.color = rgbToHex(type.color)
      }
      return type
    })
    tags = zone.tags;
  }

  function rgbToHex(rgbString) {
    const result = rgbString.match(/\d+/g);
    const arr = result.map(Number);
    const redHex = arr[0].toString(16).padStart(2, '0');
    const greenHex = arr[1].toString(16).padStart(2, '0');
    const blueHex = arr[2].toString(16).padStart(2, '0');
    return `#${redHex}${greenHex}${blueHex}`;
  }


  const maxId = (t) => t.reduce((acc, type) => Math.max(acc, type.id), -1) || 0;

  function handleTypeAddClick() {
    const randomColor = 'rgb(' + [Math.floor(Math.random() * 256), Math.floor(Math.random() * 256), Math.floor(Math.random() * 256)].join(',') + ')';
    console.log(randomColor);

    types = [...types, {id: maxId(types) + 1, label: "", color: rgbToHex(randomColor)}];
  }

  function handleTagAddClick() {


    tags = [...tags, {id: maxId(tags) + 1, label: ""}];
  }


  function handleSaveSettingsClick() {

    _zone.types = types.map((type) => {
      if (type.label.length === 0) {
        type.label = "_"
      }
      return type
    });

    _zone.tags = tags.map((tag) => {
      if (tag.label.length === 0) {
        tag.label = "_"
      }
      return tag
    });


    apiService.updateZone(_zone).then(a => {
      _zone = {id: undefined};
      emit('done', a);
      savedToast = true;
      setTimeout(() => {
        savedToast = false;
      }, 2000);
    }).catch(alert);

  }


</script>
<style>
    .color-picker {
        border: none;
        height: 42px;
        padding: 0;
        margin: 0;
        background: transparent;
    }

    .hidden-value {
        opacity: 0.3;
    }


</style>