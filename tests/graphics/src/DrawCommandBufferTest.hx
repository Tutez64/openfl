package;

#if !flash
import openfl.display.GradientType;
import openfl.display.InterpolationMethod;
import openfl.display.SpreadMethod;
import openfl.display._internal.DrawCommandBuffer;
import utest.Assert;
import utest.Test;

@:access(openfl.display._internal.DrawCommandBuffer)
class DrawCommandBufferTest extends Test
{
	public function testStorageIsAllocatedOnlyWhenUsed()
	{
		var empty = new DrawCommandBuffer();
		var commands = new DrawCommandBuffer();

		commands.beginFill(0xFF0000, 1);

		Assert.isFalse(commands.types == empty.types);
		Assert.isFalse(commands.i == empty.i);
		Assert.isFalse(commands.f == empty.f);
		Assert.isTrue(commands.b == empty.b);
		Assert.isTrue(commands.o == empty.o);
		Assert.isTrue(commands.ff == empty.ff);
		Assert.isTrue(commands.ii == empty.ii);

		commands.beginBitmapFill(null, null, true, false);

		Assert.isFalse(commands.b == empty.b);
		Assert.isFalse(commands.o == empty.o);
		Assert.isTrue(commands.ff == empty.ff);
		Assert.isTrue(commands.ii == empty.ii);

		commands.beginGradientFill(GradientType.LINEAR, [0], [1], [0], null, SpreadMethod.PAD, InterpolationMethod.RGB, 0);

		Assert.isFalse(commands.ff == empty.ff);
		Assert.isFalse(commands.ii == empty.ii);
	}

	public function testCopyOnWriteIsIndependentPerStorage()
	{
		var source = new DrawCommandBuffer();
		source.beginFill(0xFF0000, 1);
		source.drawRect(0, 0, 10, 10);

		var copy = source.copy();

		Assert.isTrue(source.types == copy.types);
		Assert.isTrue(source.i == copy.i);
		Assert.isTrue(source.f == copy.f);

		copy.lineTo(20, 20);

		Assert.isFalse(source.types == copy.types);
		Assert.isTrue(source.i == copy.i);
		Assert.isFalse(source.f == copy.f);
		Assert.equals(2, source.length);
		Assert.equals(3, copy.length);

		source.beginFill(0x00FF00, 0.5);

		Assert.isFalse(source.i == copy.i);
		Assert.equals(2, source.i.length);
		Assert.equals(1, copy.i.length);
		Assert.equals(3, source.length);
		Assert.equals(3, copy.length);
	}

	public function testClearRestoresLazyStorage()
	{
		var empty = new DrawCommandBuffer();
		var commands = new DrawCommandBuffer();

		commands.beginGradientFill(GradientType.LINEAR, [0], [1], [0], null, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
		commands.clear();
		commands.beginFill(0xFF0000, 1);

		Assert.isFalse(commands.types == empty.types);
		Assert.isFalse(commands.i == empty.i);
		Assert.isFalse(commands.f == empty.f);
		Assert.isTrue(commands.b == empty.b);
		#if haxe4
		// clear() keeps the arrays the gradient fill copied, emptied
		Assert.isFalse(commands.o == empty.o);
		Assert.isFalse(commands.ff == empty.ff);
		Assert.isFalse(commands.ii == empty.ii);
		#else
		Assert.isTrue(commands.o == empty.o);
		Assert.isTrue(commands.ff == empty.ff);
		Assert.isTrue(commands.ii == empty.ii);
		#end
		Assert.equals(0, commands.o.length);
		Assert.equals(0, commands.ff.length);
		Assert.equals(0, commands.ii.length);
	}

	public function testClearKeepsTheStorageItOwns()
	{
		var commands = new DrawCommandBuffer();
		commands.moveTo(1, 2);
		commands.lineTo(3, 4);

		var types = commands.types;
		var f = commands.f;
		var i = commands.i;

		commands.clear();

		Assert.equals(0, commands.length);
		#if haxe4
		Assert.isTrue(commands.types == types);
		Assert.isTrue(commands.f == f);
		#end
		Assert.equals(0, commands.f.length);
		// An array no command wrote to is still the one every empty buffer shares
		Assert.isTrue(commands.i == i);

		commands.lineTo(5, 6);

		Assert.equals(1, commands.length);
		Assert.equals(5.0, commands.f[0]);
		Assert.equals(6.0, commands.f[1]);

		// An array written to after a partial clear is copied, not written in place
		commands.beginFill(0xFF0000, 1);
		Assert.isFalse(commands.i == i);
		Assert.equals(0, new DrawCommandBuffer().length);
	}

	public function testClearLeavesSharedStorage()
	{
		var source = new DrawCommandBuffer();
		source.moveTo(1, 2);
		source.lineTo(3, 4);

		var copy = source.copy();
		Assert.isTrue(source.f == copy.f);

		source.clear();

		Assert.equals(0, source.length);
		Assert.equals(2, copy.length);
		Assert.equals(4, copy.f.length);
		Assert.equals(3.0, copy.f[2]);

		source.lineTo(7, 8);

		Assert.equals(1, source.length);
		Assert.equals(2, copy.length);
		Assert.equals(1.0, copy.f[0]);
		Assert.equals(7.0, source.f[0]);
	}
}
#end
