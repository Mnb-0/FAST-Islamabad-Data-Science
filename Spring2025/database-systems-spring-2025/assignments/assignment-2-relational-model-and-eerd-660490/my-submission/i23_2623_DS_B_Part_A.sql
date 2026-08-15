create database DBA2;
use DBA2;

create table Student (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    Contact VARCHAR(20),
    Department VARCHAR(50),
    GroupID INT NOT NULL,
    FOREIGN KEY (GroupID) REFERENCES GroupTable(GroupID)
);

create table GroupTable (
    GroupID INT PRIMARY KEY,
    ProjectTitle VARCHAR(255) NOT NULL,
    ProjectID INT UNIQUE NOT NULL,
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

create table Project (
    ProjectID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Description TEXT
);


create table Faculty (
    FacultyID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    Contact VARCHAR(20),
    Department VARCHAR(50)
);

create table Supervision (
    ProjectID INT NOT NULL,
    FacultyID INT NOT NULL,
    PRIMARY KEY (ProjectID, FacultyID),
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID) ON DELETE CASCADE,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID) ON DELETE CASCADE
);

create table Evaluation (
    EvaluationID INT PRIMARY KEY,
    Phase ENUM('Proposal', 'Mid-Term', 'Final') NOT NULL,
    Date DATE NOT NULL,
    Status VARCHAR(50),
    ProjectID INT,
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

create table Evaluators (
    EvaluationID INT NOT NULL,
    FacultyID INT NOT NULL,
    PRIMARY KEY (EvaluationID, FacultyID),
    FOREIGN KEY (EvaluationID) REFERENCES Evaluation(EvaluationID) ON DELETE CASCADE,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID) ON DELETE CASCADE
);

create table ProjectVersion (
    VersionID INT PRIMARY KEY,
    ModificationDate DATE NOT NULL,
    Changes TEXT,
    Status VARCHAR(50),
    ProjectID INT,
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID) ON DELETE SET NULL
);

create table Feedback (
    FeedbackID INT PRIMARY KEY,
    Comments TEXT NOT NULL,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    VersionID INT,
    FacultyID INT NOT NULL,
    FOREIGN KEY (VersionID) REFERENCES ProjectVersion(VersionID) ON DELETE SET NULL,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID) ON DELETE CASCADE
);

create table EvaluationScore (
    EvaluationID INT NOT NULL,
    FacultyID INT NOT NULL,
    Score INT CHECK (Score BETWEEN 0 AND 100),
    Comment TEXT,
    PRIMARY KEY (EvaluationID, FacultyID),
    FOREIGN KEY (EvaluationID) REFERENCES Evaluation(EvaluationID) ON DELETE CASCADE,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID) ON DELETE CASCADE
);

select * from evaluation;
select * from evaluationscore;
select * from evaluators;
select * from faculty;
select * from feedback;
select * from grouptable;
select * from project;
select * from projectversion;
select * from student;
select * from supervision;







-- Insert Groups
insert into GroupTable (GroupID, ProjectTitle, ProjectID) values
(1, 'AI Chatbot', 101),
(2, 'Smart Traffic System', 102),
(3, 'E-Learning Platform', 103),
(4, 'Blockchain Voting System', 104),
(5, 'Autonomous Drone Navigation', 105);

-- Insert Projects
insert into Project (ProjectID, Title, Description) values
(101, 'AI Chatbot', 'An AI-based chatbot for customer support.'),
(102, 'Smart Traffic System', 'A system using AI to optimize traffic lights.'),
(103, 'E-Learning Platform', 'A platform for online education with interactive features.'),
(104, 'Blockchain Voting System', 'A blockchain-based secure voting platform.'),
(105, 'Autonomous Drone Navigation', 'An AI-driven drone navigation system.');

-- Insert Faculty
insert into Faculty (FacultyID, FirstName, LastName, Email, Contact, Department) values
(201, 'John', 'Doe', 'johndoe@university.edu', '123-456-7890', 'Computer Science'),
(202, 'Jane', 'Smith', 'janesmith@university.edu', '234-567-8901', 'Information Technology'),
(203, 'Robert', 'Brown', 'robertbrown@university.edu', '345-678-9012', 'Electronics'),
(204, 'Emily', 'White', 'emilywhite@university.edu', '456-789-0123', 'Artificial Intelligence'),
(205, 'Michael', 'Clark', 'michaelclark@university.edu', '567-890-1234', 'Cybersecurity');

-- Insert Students
insert into Student (StudentID, FirstName, LastName, Email, Contact, Department, GroupID) values
(301, 'Alice', 'Johnson', 'alicej@university.edu', '678-901-2345', 'Computer Science', 1),
(302, 'Bob', 'Williams', 'bobw@university.edu', '789-012-3456', 'Computer Science', 1),
(303, 'Charlie', 'Miller', 'charliem@university.edu', '890-123-4567', 'Information Technology', 2),
(304, 'David', 'Davis', 'davidd@university.edu', '901-234-5678', 'Information Technology', 2),
(305, 'Ella', 'Moore', 'ellam@university.edu', '012-345-6789', 'Electronics', 3),
(306, 'Frank', 'Taylor', 'frankt@university.edu', '123-456-7891', 'Electronics', 3),
(307, 'Grace', 'Anderson', 'gracea@university.edu', '234-567-8902', 'Artificial Intelligence', 4),
(308, 'Henry', 'Martinez', 'henrym@university.edu', '345-678-9013', 'Artificial Intelligence', 4),
(309, 'Ivy', 'Hernandez', 'ivyh@university.edu', '456-789-0124', 'Cybersecurity', 5),
(310, 'Jack', 'Lopez', 'jackl@university.edu', '567-890-1235', 'Cybersecurity', 5);

-- Insert Supervision (Faculty supervising Projects)
insert into Supervision (ProjectID, FacultyID) values
(101, 201),
(102, 202),
(103, 203),
(104, 204),
(105, 205),
(101, 204),
(102, 203);

-- Insert Evaluations
insert into Evaluation (EvaluationID, Phase, Date, Status, ProjectID) values
(401, 'Proposal', '2025-03-01', 'Pending', 101),
(402, 'Mid-Term', '2025-04-15', 'Completed', 102),
(403, 'Final', '2025-06-01', 'Pending', 103),
(404, 'Proposal', '2025-03-05', 'Pending', 104),
(405, 'Mid-Term', '2025-04-20', 'Completed', 105);

-- Insert Evaluators (Faculty evaluating projects)
insert into Evaluators (EvaluationID, FacultyID) values
(401, 202),
(401, 203),
(402, 204),
(403, 205),
(404, 201),
(405, 202),
(405, 203);

-- Insert Project Versions
insert into ProjectVersion (VersionID, ModificationDate, Changes, Status, ProjectID) values
(501, '2025-03-10', 'Initial draft completed', 'Approved', 101),
(502, '2025-04-18', 'Added new AI module', 'Pending Review', 102),
(503, '2025-05-05', 'Security enhancements', 'Approved', 103),
(504, '2025-06-02', 'Updated blockchain algorithm', 'In Progress', 104),
(505, '2025-06-10', 'Refactored navigation code', 'Approved', 105);

-- Insert Feedback
insert into Feedback (FeedbackID, Comments, Timestamp, VersionID, FacultyID) values
(601, 'Great work, but needs more testing.', '2025-03-11 10:30:00', 501, 201),
(602, 'Consider optimizing performance.', '2025-04-19 14:00:00', 502, 202),
(603, 'Security improvements are impressive.', '2025-05-06 16:45:00', 503, 203),
(604, 'More documentation is needed.', '2025-06-03 12:20:00', 504, 204),
(605, 'Navigation system looks promising.', '2025-06-11 09:10:00', 505, 205);

-- Insert Evaluation Scores
insert into EvaluationScore (EvaluationID, FacultyID, Score, Comment) values
(401, 202, 85, 'Good start, but needs refinement.'),
(401, 203, 78, 'Solid proposal, but missing key details.'),
(402, 204, 90, 'Well-structured, implementation is on track.'),
(403, 205, 88, 'Final product is nearly complete and functional.'),
(404, 201, 80, 'A promising approach, but feasibility concerns.'),
(405, 202, 92, 'Excellent improvements over the initial plan.'),
(405, 203, 87, 'Neat work with solid technical aspects.');

select 
    p.ProjectID,
    p.Title,
    AVG(es.Score) AS AverageScore
from EvaluationScore es
join Evaluation e ON es.EvaluationID = e.EvaluationID
join Project p ON e.ProjectID = p.ProjectID
group BY p.ProjectID, p.Title
order BY AverageScore DESC;

select 
    f.FacultyID,
    CONCAT(f.FirstName, ' ', f.LastName) AS FullName,
    COALESCE(s.ProjectCount, 0) AS ProjectsSupervised,
    COALESCE(evals.EvaluationsParticipated, 0) AS EvaluationsParticipated,
    COALESCE(fb.FeedbackCount, 0) AS FeedbackProvided
from Faculty f
left join (
    select FacultyID, COUNT(*) AS ProjectCount
    from Supervision
    group BY FacultyID
) s ON f.FacultyID = s.FacultyID
left join (
    select FacultyID, COUNT(*) AS EvaluationsParticipated
    from Evaluators
    group BY FacultyID
) evals ON f.FacultyID = evals.FacultyID
left join (
    select FacultyID, COUNT(*) AS FeedbackCount
    from Feedback
    group BY FacultyID
) fb ON f.FacultyID = fb.FacultyID
order BY f.FacultyID;

select 
    pv.ProjectID,
    p.Title,
    AVG(DATEDIFF(f.Timestamp, pv.ModificationDate)) AS AvgDaysToFeedback
from ProjectVersion pv
join Feedback f ON pv.VersionID = f.VersionID
join Project p ON pv.ProjectID = p.ProjectID
group BY pv.ProjectID, p.Title
order BY AvgDaysToFeedback;

select
    p.ProjectID,
    p.Title,
    COALESCE(ev.EvalCount, 0) AS EvaluationCount,
    COALESCE(pv.VersionCount, 0) AS VersionCount,
    COALESCE(fb.FeedbackCount, 0) AS FeedbackCount,
    (COALESCE(ev.EvalCount, 0) + COALESCE(pv.VersionCount, 0) + COALESCE(fb.FeedbackCount, 0)) AS ActivityIndex
from Project p
left join (
    select ProjectID, COUNT(*) AS EvalCount
    from Evaluation
    group BY ProjectID
) ev ON p.ProjectID = ev.ProjectID
left join (
    select ProjectID, COUNT(*) AS VersionCount
    from ProjectVersion
    group BY ProjectID
) pv ON p.ProjectID = pv.ProjectID
left join (
    select pv.ProjectID, COUNT(*) AS FeedbackCount
    from Feedback f
    join ProjectVersion pv ON f.VersionID = pv.VersionID
    group BY pv.ProjectID
) fb ON p.ProjectID = fb.ProjectID
order BY ActivityIndex DESC;

select 
    Phase,
    COUNT(*) AS EvaluationCount
from Evaluation
group BY Phase
order BY EvaluationCount DESC;
