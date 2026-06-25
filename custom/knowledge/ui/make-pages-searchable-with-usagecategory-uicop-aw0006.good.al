page 50100 "Customer Insights List"
{
    PageType = List;
    SourceTable = Customer;
    ApplicationArea = All;        // visible regardless of application-area profile
    UsageCategory = Lists;        // places the page in the Tell-Me "Lists" group

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
            }
        }
    }
}
