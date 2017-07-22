package bot.driver.script;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import bot.driver.Movement;
import bot.driver.Setpoints;

// comando walk
// [ \t]*walk[ \t]+[0-9]+[ \t]*(m|cm)[ \t]*

// comando rotate
// [ \t]*rotate[ \t]+(to|by)[ \t]+[0-9]+[ \t]*(deg|rad)[ \t]*

// comando sleep
// [ \t]*sleep[ \t]+[0-9]+[ \t]*(min|m|sec|s|millis|msec|ms)[ \t]*

// comentário
// [ \t]*//.*
// "[ \\t]*//.*"

public class MovementScript {
	private class ScriptMovement implements Movement {
		private Iterator<Object> m_iterator;
		private long m_wait;
		private Setpoints m_setpoints;

		public ScriptMovement(Iterator<Object> iterator) {
			m_iterator = iterator;
			m_setpoints = new Setpoints();
			this.next();
		}

		@Override
		public long getSleep() {
			return m_wait;
		}

		@Override
		public void getSetpoint(Setpoints target) {
			target.legNE_x = m_setpoints.legNE_x;
			target.legNE_y = m_setpoints.legNE_y;
			target.legNE_z = m_setpoints.legNE_z;
			target.legE_x = m_setpoints.legE_x;
			target.legE_y = m_setpoints.legE_y;
			target.legE_z = m_setpoints.legE_z;
			target.legSE_x = m_setpoints.legSE_x;
			target.legSE_y = m_setpoints.legSE_y;
			target.legSE_z = m_setpoints.legSE_z;
			target.legNW_x = m_setpoints.legNW_x;
			target.legNW_y = m_setpoints.legNW_y;
			target.legNW_z = m_setpoints.legNW_z;
			target.legW_x = m_setpoints.legW_x;
			target.legW_y = m_setpoints.legW_y;
			target.legW_z = m_setpoints.legW_z;
			target.legSW_x = m_setpoints.legSW_x;
			target.legSW_y = m_setpoints.legSW_y;
			target.legSW_z = m_setpoints.legSW_z;
		}

		@Override
		public void next() {
			if (m_iterator == null) {
				return;
			}
			m_wait = 0;
			if (m_iterator.hasNext()) {
				Object next = m_iterator.next();
				if (next == null) {
					return;
				}
				if (next instanceof Attribution) {
					((Attribution) next).execute(m_setpoints);
				}
				if (next instanceof Sleep) {
					m_wait += ((Sleep) next).timeMs;
				}

			}
			m_iterator = null;
		}

		@Override
		public boolean hasEnded() {
			return m_iterator != null;
		}

	}

	private List<Object> m_instructions;

	private MovementScript(List<Object> instructions) {
		m_instructions = instructions;
	}

	public Movement getMovement() {
		return new ScriptMovement(m_instructions.iterator());
	}

	public static MovementScript parse(String script) {
		List<Object> instructions = new ArrayList<Object>();
		BufferedReader reader = new BufferedReader(new StringReader(script));
		try {
			int lineNumber = 1;
			for (String line = reader.readLine(); line != null; line = reader.readLine()) {
				try {
					if (!Sleep.tryMatch(lineNumber, line, instructions)) {
						if (!Attribution.tryMatch(lineNumber, line, instructions)) {
							throw new ParseException(lineNumber);
						}
					}
				} catch (ParseException e) {
					e.printStackTrace();
				}
				lineNumber++;
			}
		} catch (IOException e) {}
		return new MovementScript(instructions);
	}

	private enum Leg {
		NE, E, SE, SW, W, NW
	}

	private static class StringHelper {
		String string;
		int index;

		public StringHelper(String string) {
			this.string = string;
		}

		private static boolean isSymbol(char c) {
			return c == '=' || c == '(' || c == ')' || c == ',';
		}

		private static boolean isSpace(char c) {
			return c == ' ' || c == '\n';
		}

		public String nextWord() {
			this.skipSpaces();
			if (index >= string.length()) {
				return "";
			}
			int start = index;
			char c = string.charAt(index);
			while (!isSpace(c) && !isSymbol(c)) {
				index++;
				if (index >= string.length()) {
					break;
				}
				c = string.charAt(index);
			}
			return string.substring(start, index);
		}

		public void skipWord() {
			this.skipSpaces();
			if (index >= string.length()) {
				return;
			}
			char c = string.charAt(index);
			while (!isSpace(c) && !isSymbol(c)) {
				index++;
				if (index >= string.length()) {
					return;
				}
				c = string.charAt(index);
			}
		}

		public void skipSymbol() {
			this.skipSpaces();
			if (index >= string.length()) {
				return;
			}
			char c = string.charAt(index);
			while (isSymbol(c)) {
				index++;
				if (index >= string.length()) {
					return;
				}
				c = string.charAt(index);
			}
		}

		public void skipSpaces() {
			if (index >= string.length()) {
				return;
			}
			char c = string.charAt(index);
			while (isSpace(c)) {
				index++;
				if (index >= string.length()) {
					return;
				}
				c = string.charAt(index);
			}
		}
	}

	@SuppressWarnings("serial")
	private static class ParseException extends Exception {
		public ParseException(int lineNumber) {
			super("Wrong format at line " + lineNumber + ": unknown instruction");

		}

		public ParseException(int lineNumber, String instructionKind) {
			super("Wrong format at line " + lineNumber + ": instruction " + instructionKind + " is not formatted accordingly");
		}
	}

	public static class Sleep {
		public long timeMs;

		public static final Pattern regexOk = Pattern.compile("[ \\t]*[wW][aA][iI][tT][ \\t]+[0-9]+[ \\t]+(([mM][iI][nN])|[sS]|([mM][sS]))[ \\t]*");

		public static final Pattern regexErr = Pattern.compile("[ \\t]*[wW][aA][iI][tT][ \\t]+.*");

		public static boolean tryMatch(int lineNumber, String line, List<Object> instructionList) throws ParseException {
			if (regexOk.matcher(line).matches()) {
				StringHelper helper = new StringHelper(line);
				helper.skipWord(); // pulou "wait"
				String time = helper.nextWord();
				String unit = helper.nextWord().toLowerCase();
				if (unit.equals("min")) {
					instructionList.add(new Sleep(Integer.parseInt(time) * 60000));
					return true;
				}
				if (unit.equals("s")) {
					instructionList.add(new Sleep(Integer.parseInt(time) * 60));
					return true;
				}
				if (unit.equals("ms")) {
					instructionList.add(new Sleep(Integer.parseInt(time)));
					return true;
				}
				return false;
			} else if (regexErr.matcher(line).matches()) {
				throw new ParseException(lineNumber, "wait");
			} else {
				return false;
			}
		}

		protected Sleep(long timeMs) {
			this.timeMs = timeMs;
		}
	}

	public static class Attribution {
		public Leg leg;
		public int x;
		public int y;
		public int z;

		public static final Pattern regexOk = Pattern.compile("[ \\t]*[mM][oO][vV][eE][ \\t]+([sSnN]?[eEwW][ \\t]*=[ \\t]*\\([ \\t]*[0-9]+[ \\t]*,[ \\t]*[0-9]+[ \\t]*,[ \\t]*[0-9]+[ \\t]*\\)[ \\t]*)+");

		public static final Pattern regexErr = Pattern.compile("[ \\t]*[mM][oO][vV][eE][ \\t]+.*");

		public static boolean tryMatch(int lineNumber, String line, List<Object> instructionList) throws ParseException {
			if (regexOk.matcher(line).matches()) {
				StringHelper helper = new StringHelper(line);
				helper.skipWord(); // pulou "move"
				String leg = helper.nextWord();
				while (leg.length() > 0) {
					helper.skipSymbol(); // =
					helper.skipSymbol(); // (
					String x = helper.nextWord();
					helper.skipSymbol(); // ,
					String y = helper.nextWord();
					helper.skipSymbol(); // ,
					String z = helper.nextWord();
					helper.skipSymbol(); // )

					Attribution attribution = new Attribution(leg, Integer.parseInt(x), Integer.parseInt(y), Integer.parseInt(z));
					instructionList.add(attribution);

					leg = helper.nextWord();
				}
				instructionList.add(null);
				return true;
			} else if (regexErr.matcher(line).matches()) {
				throw new ParseException(lineNumber, "move");
			} else {
				return false;
			}
		}

		protected Attribution(String leg, int x, int y, int z) {
			System.out.println("Set leg " + leg.toUpperCase() + " = (" + x + ", " + y + ", " + z + ")");
			this.leg = Leg.valueOf(leg.toUpperCase());
			this.x = x;
			this.y = y;
			this.z = z;
		}

		public void execute(Setpoints setpoint) {
			switch (leg) {
				case NE:
					setpoint.legNE_x = x;
					setpoint.legNE_y = y;
					setpoint.legNE_z = z;
					break;
				case E:
					setpoint.legE_x = x;
					setpoint.legE_y = y;
					setpoint.legE_z = z;
					break;
				case SE:
					setpoint.legSE_x = x;
					setpoint.legSE_y = y;
					setpoint.legSE_z = z;
					break;
				case SW:
					setpoint.legSW_x = x;
					setpoint.legSW_y = y;
					setpoint.legSW_z = z;
					break;
				case W:
					setpoint.legW_x = x;
					setpoint.legW_y = y;
					setpoint.legW_z = z;
					break;
				case NW:
					setpoint.legNW_x = x;
					setpoint.legNW_y = y;
					setpoint.legNW_z = z;
					break;
			}
		}
	}
}
