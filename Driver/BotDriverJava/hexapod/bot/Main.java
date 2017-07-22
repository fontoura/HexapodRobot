package bot;

import bot.driver.ClientManager;
import bot.driver.DriverManager;
import bot.driver.RobotManager;

public class Main {
	public static void main(String[] args) {
		DriverManager driver = DriverManager.create();
		RobotManager robot = RobotManager.create(driver);
		ClientManager client = ClientManager.create(driver);
		driver.setRobot(robot);
		driver.setClient(client);
		client.run();
	}

}
