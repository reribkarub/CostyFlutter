import 'dart:io';

import 'package:costy/keys.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:ozzie/ozzie.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  FlutterDriver driver;
  Ozzie ozzie;

  // Connect to the Flutter driver before running any tests.
  setUpAll(() async {
    driver = await FlutterDriver.connect();
    ozzie = Ozzie.initWith(driver, groupName: 'expenses');
    sleep(const Duration(seconds: 1));
  });

  // Close the connection to the driver after the tests have completed.
  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
    ozzie.generateHtmlReport();
  });

  test('check flutter driver health', () async {
    final health = await driver.checkHealth();
    expect(health.status, HealthStatus.ok);
  });

  testWithScreenshots(
      'should display proper text when there is no expenses yet', () => ozzie,
      () async {
    await createProject("Project1", "PLN", driver);

    await tapOnText('Project1', driver);

    await expectTextPresent("No expenses to display.", driver);
  });

  testWithScreenshots(
      'should display message when user tries to add expense with no users',
      () => ozzie, () async {
    await tapOnKey(Keys.projectDetailsAddExpenseButton, driver);

    await expectTextPresent("Please add some users first.", driver);

    await tapOnKey(Keys.alertDialogOkButton, driver);
  });

  testWithScreenshots('should add expense with default values', () => ozzie,
      () async {
    await tapOnKey(Keys.projectDetailsUsersTab, driver);

    await createUser('John', driver);
    await createUser('Kate', driver);

    await tapOnKey(Keys.projectDetailsExpensesTab, driver);

    await createExpense(
        "Test description", "11", "John", "John => John, Kate", driver);
  });

  testWithScreenshots('should edit created expense', () => ozzie, () async {
    await driver.tap(find.byValueKey("0_expense_edit"));

    await expectKeyPresent(Keys.expenseFormDescriptionFieldKey, driver);
    await tapOnKey(Keys.expenseFormDescriptionFieldKey, driver);
    await driver.enterText("Edited description");
    await driver.waitFor(find.text('Edited description'));

    await expectKeyPresent(Keys.expenseFormAcountFieldKey, driver);
    await tapOnKey(Keys.expenseFormAcountFieldKey, driver);
    await driver.enterText("12");
    await driver.waitFor(find.text('12'));

    await expectKeyPresent(Keys.expenseFormUserKey, driver);
    await tapOnKey(Keys.expenseFormUserKey, driver);
    await driver.tap(find.text("Kate"));

    await expectKeyPresent(Keys.expenseFormAddEditButtonKey, driver);
    await tapOnKey(Keys.expenseFormAddEditButtonKey, driver);

    await expectTextPresent("Edited description", driver);
    await expectTextPresent("Kate => John, Kate", driver);
    await expectTextPresent("12", driver);
  });

  testWithScreenshots('should delete created expense', () => ozzie, () async {
    await driver.scroll(find.byValueKey("expense_0"), -400, 0,
        const Duration(milliseconds: 300));

    await expectKeyPresent(Keys.deleteConfirmationDeleteButton, driver);
    await tapOnKey(Keys.deleteConfirmationDeleteButton, driver);

    await expectTextPresent("No expenses to display.", driver);
  });
}
