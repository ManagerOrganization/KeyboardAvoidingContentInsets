
@interface KeyboardAvoidingViewController ()

@property (nonatomic, weak) UITextField *currentTextField;
@property (nonatomic, weak) NSIndexPath *currentCellPath;

@end



@implementation KeyboardAvoidingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerKeyboardNotifications];
}

- (void)dealloc
{
    [self unregisterKeyboardNotifications];
}

#pragma mark - TABLE VIEW DELEGATES
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableViewSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Add text field to content view of standard cell
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 4, CGRectGetWidth(cellRect), CGRectGetHeight(cellRect) - 4)];
        [cell.contentView addSubview:textField];
    }
    
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;

    return cell;
}

#pragma mark - UITextField delegate methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    self.currentCellPath = [self.tableView indexPathForCell:cell];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentTextField = nil;
    self.currentCellPath = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIKeyboard methods

- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGPoint scrollPoint = CGPointZero;
    CGRect visibleArea = self.view.frame;
    visibleArea.size.height -= CGRectGetHeight(keyboardRect);
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.currentCellPath]; //find cell location in table

    cellRect = CGRectOffset(cellRect, self.tableView.frame.origin.x, self.tableView.frame.origin.y); //offset for tables location in view
    
    
    CGPoint visiblePoint = CGPointMake(0, cellRect.origin.y + CGRectGetHeight(self.currentTextField.frame) + CGRectGetMaxY(self.currentTextField.frame)); //offset cell location with textfield location
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, scrollPoint.y, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    //scroll if obscured by keyboard
    if (!CGRectContainsPoint(visibleArea, visiblePoint) ) {
        scrollPoint = CGPointMake(0.0, visiblePoint.y - keyboardRect.origin.y);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //reset insets without keyboard
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }];
    }


@end
