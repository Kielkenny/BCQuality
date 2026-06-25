page 50100 "Customer Insights List"
{
    PageType = List;
    SourceTable = Customer;
    // No ApplicationArea, no UsageCategory: this page compiles but never shows
    // up in Tell-Me search, so a user cannot open it directly. UICop AW0006.

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
