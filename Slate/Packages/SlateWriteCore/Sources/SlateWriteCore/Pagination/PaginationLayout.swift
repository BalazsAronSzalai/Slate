import Foundation

/// Industry-standard screenplay layout constants for pagination.
/// All measurements are in inches unless otherwise noted.
/// Based on Final Draft 13 standard layout.
public enum PaginationLayout {
    
    // MARK: - Font Metrics
    
    /// Courier Prime at 12pt = 10 characters per inch (cpi)
    public static let characterWidth: Double = 0.1
    
    /// Line height = 12pt = 1/6 inch (exactly, no system leading)
    public static let lineHeight: Double = 1.0 / 6.0
    
    // MARK: - Page Metrics
    
    /// Number of content lines per page (55 lines = 11" - 1" top - ~1" bottom)
    public static let linesPerPage: Int = 55
    
    /// Left margin from paper edge
    public static let leftMargin: Double = 1.5
    
    /// Right margin from paper edge
    public static let rightMargin: Double = 1.0
    
    /// Top margin from paper edge
    public static let topMargin: Double = 1.0
    
    /// Bottom margin from paper edge
    public static let bottomMargin: Double = 1.0
    
    // MARK: - Element Widths (in characters at 10cpi)
    
    /// Scene heading width: 60 characters (6 inches at 10cpi)
    public static let sceneHeadingWidth: Int = 60
    
    /// Action width: 60 characters (6 inches at 10cpi)
    public static let actionWidth: Int = 60
    
    /// Dialogue width: ~35 characters (3.5 inches at 10cpi)
    public static let dialogueWidth: Int = 35
    
    /// Parenthetical width: ~26 characters (2.6 inches at 10cpi)
    public static let parentheticalWidth: Int = 26
    
    // MARK: - Element Indents (in inches from left paper edge)
    
    /// Scene heading indent: 1.5 inches
    public static let sceneHeadingIndent: Double = 1.5
    
    /// Action indent: 1.5 inches
    public static let actionIndent: Double = 1.5
    
    /// Character cue indent: 3.7 inches
    public static let characterIndent: Double = 3.7
    
    /// Parenthetical indent: 3.1 inches
    public static let parentheticalIndent: Double = 3.1
    
    /// Dialogue indent: 2.5 inches
    public static let dialogueIndent: Double = 2.5
    
    /// Transition right-aligned to 7.5 inches
    public static let transitionRightMargin: Double = 7.5
    
    // MARK: - Revision Mark Position
    
    /// Revision mark asterisk column: 7.9 inches from left edge
    public static let revisionMarkColumn: Double = 7.9
}
