import { std } from "wow/wotlk";

const FLYING_BOOK = std.CreatureTemplates
    .create('flying-book','flying-book-creature')
    .Name.enGB.set('Flying Book')
    .Level.set(80)
    .Type.DEMON.set()
    .Stats.set(50000, 0, 5000, 500, 1)

FLYING_BOOK.Models.addSimple('flying-book', 'FlyingBookModel', 'creature\\FlyingBook\\FlyingBook.m2', 1)
FLYING_BOOK.Models.get(0).modRef(display => {
    display.TextureVariation.set(0, 'creature\\FlyingBook\\FlyingBook01_blue.blp')
})
FLYING_BOOK.Spawns.add('flying-book','spawn1', {map:0, x:-8900, y:-120, z:80, o:0})

console.log('Created Flying Book creature!');
