<g cursor="pointer">
    <rect class:selected={isSelected} cursor="pointer" fill={fill} height={height} id={key} stroke={stroke} width={width} x={x} y={y}/>
    <text class:selectedText={isSelected} cursor="pointer" fill={fontColor} font-size={fontSize} text-anchor="middle" x={x+(width/2)} y={y+(height/2+fontShift)}>{text}</text>
</g>

<script>

  export let x = 0;
  export let y = 0;
  export let width = 30;
  export let height = 30;
  export let text = "1";
  export let fontSize = 12;
  export let key;

  import {main, selectedKeys} from "../lib/MainStore";

  let type = undefined

  const fontShift = height / 20

  $: type = $main[key]
  $: isSelected = $selectedKeys[key]

  $: stroke = isSelected ? 'red' : '#000'

  $: fill = type ? type.color : 'transparent'
  $: fontColor = type ? '#fff' : (isSelected ? '#000' : '#ccc')


</script>
<style>
    .selected {
        fill: url(#diagonalHatch);
        stroke: black;
        /*outline: 3px double black;*/
        /*outline-offset: -3px;*/
    }

    .selectedText {
        fill: black
    }
</style>