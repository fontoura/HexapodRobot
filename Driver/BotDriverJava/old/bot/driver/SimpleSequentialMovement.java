package bot.driver;

import java.util.List;

public class SimpleSequentialMovement implements Movement {
	private List<Setpoints> m_setpointsList;
	private int m_index;

	public SimpleSequentialMovement(List<Setpoints> setpointList) {
		m_setpointsList = setpointList;
		if (setpointList != null) {
			if (setpointList.size() == 0) {
				m_setpointsList = null;
			}
		}
	}

	@Override
	public long getSleep() {
		return 0;
	}

	@Override
	public void getSetpoint(Setpoints target) {
		if (m_setpointsList != null) {
			Setpoints source = m_setpointsList.get(m_index);
			target.legNE_x = source.legNE_x;
			target.legNE_y = source.legNE_y;
			target.legNE_z = source.legNE_z;
			target.legE_x = source.legE_x;
			target.legE_y = source.legE_y;
			target.legE_z = source.legE_z;
			target.legSE_x = source.legSE_x;
			target.legSE_y = source.legSE_y;
			target.legSE_z = source.legSE_z;
			target.legNW_x = source.legNW_x;
			target.legNW_y = source.legNW_y;
			target.legNW_z = source.legNW_z;
			target.legW_x = source.legW_x;
			target.legW_y = source.legW_y;
			target.legW_z = source.legW_z;
			target.legSW_x = source.legSW_x;
			target.legSW_y = source.legSW_y;
			target.legSW_z = source.legSW_z;
		}
	}

	@Override
	public void next() {
		m_index++;
		if (m_index >= m_setpointsList.size()) {
			m_setpointsList = null;
		}
	}

	@Override
	public boolean hasEnded() {
		return m_setpointsList == null;
	}

}
