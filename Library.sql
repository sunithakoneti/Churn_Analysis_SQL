drop database if exists library_assignment;
create database library_assignment;
use library_assignment;
create table publisher(
publisher_PublisherName varchar(100) primary key,
publisher_PublisherAddress varchar(100),
publisher_PublisherPhone varchar(50));
select* from publisher;

create table books(
book_BookID int auto_increment primary key,
book_Title varchar(100),
book_PublisherName varchar(50),
foreign key(book_Publishername) references publisher(publisher_publisherName));
select* from books; 

create table authors(
book_authors_AuthorID int auto_increment primary key,
book_authors_BookID int ,
book_authors_AuthorName varchar(50),
foreign key(book_authors_BookID) references books(book_BookID));
select * from authors;

create table library_branch(
library_branch_BranchID int auto_increment primary key,
library_branch_BranchName varchar(100),
library_branch_BranchAddress varchar(100));
select* from library_branch;
drop table book_copies;
create table book_copies(
book_copies_copyID int auto_increment primary key,
book_copies_BookID int,
book_copies_BranchID int,
book_copies_No_Of_Copies int,
foreign key(book_copies_BookID) references books(book_BookID),
foreign key(book_copies_BranchID) references library_branch(library_branch_BranchID));
select * from book_copies;
create table borrower(
borrower_CardNo int auto_increment primary key,
borrower_BorrowerName varchar(100),
borrower_BorrowerAddress varchar(100),
borrower_BorrowerPhone varchar(100));
select * from borrower; 
drop table book_loans;
create table book_loans(
book_loans_LoansID int auto_increment primary key,
book_loans_BookID int,
book_loans_BranchID int,
book_loans_CardNo int,
book_loans_DateOut date,
book_loans_DueDate date,
foreign key(book_loans_BookID) references books(book_BookID),
foreign key(book_loans_BranchID) references library_branch(library_branch_BranchID),
foreign key(book_loans_CardNo) references borrower(borrower_CardNo));
select * from book_loans;
-- ================================================================ QUESTIONS AND ANSWERS ===============================================================================
-- 1. How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
SELECT b.book_Title,bc.book_copies_No_Of_Copies,lb.library_branch_BranchName
FROM books as b
JOIN book_copies as bc ON b.book_BookID = bc.book_copies_BookID
JOIN library_branch as lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe' AND lb.library_branch_BranchName = 'Sharpstown';
-- Anser : The Lost Tribe	5	Sharpstown

-- 2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?
SELECT b.book_Title,sum(bc.book_copies_No_Of_Copies)  as Total_copies,lb.library_branch_BranchName
FROM books as b
JOIN book_copies as bc ON b.book_BookID = bc.book_copies_BookID
JOIN library_branch as lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE b.book_Title = 'The Lost Tribe' 
group by lb.library_branch_BranchName;
/* Answer
The Lost Tribe	5	Sharpstown
The Lost Tribe	5	Central
The Lost Tribe	5	Saline
The Lost Tribe	5	Ann Arbor  */

-- 3. Retrieve the names of all borrowers who do not have any books checked out.
SELECT bw.borrower_BorrowerName
FROM borrower as bw
LEFT JOIN book_loans as bl ON bw.borrower_CardNo = bl.book_loans_CardNo
WHERE bl.book_loans_CardNo IS NULL;
SELECT  borrower_Borrowername FROM borrower WHERE borrower_CardNo NOT IN
(SELECT book_loans_CardNo FROM book_loans);

-- Answer : Jane Smith

-- 4. For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 
SELECT b.book_Title, bw.borrower_BorrowerName, bw.borrower_BorrowerAddress
FROM bookS AS b
JOIN book_loans as bl ON b.book_BookID = bl.book_loans_BookID
JOIN borrower as bw ON bl.book_loans_CardNo = bw.borrower_CardNo
JOIN library_branch as lb ON bl.book_loans_BranchID = lb.library_branch_BranchID
WHERE lb.library_branch_BranchName = 'Sharpstown' AND bl.book_loans_DueDate = '0002-03-18';
/*
The Hobbit	Tom Li	981 Main Street, Ann Arbor, MI 48104
Eragon	Tom Li	981 Main Street, Ann Arbor, MI 48104
A Wise Mans Fear	Tom Li	981 Main Street, Ann Arbor, MI 48104
Harry Potter and the Philosophers Stone	Tom Li	981 Main Street, Ann Arbor, MI 48104
Hard Boiled Wonderland and The End of the World	Tom Li	981 Main Street, Ann Arbor, MI 48104
The Hitchhikers Guide to the Galaxy	Tom Li	981 Main Street, Ann Arbor, MI 48104 */
 
-- 5. For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
SELECT lb.library_branch_BranchName, COUNT(*) as TotalBooksLoaned
FROM library_branch as lb
JOIN book_loans as bl ON lb.library_branch_BranchID = bl.book_loans_BranchID
GROUP BY lb.library_branch_BranchName;
/* Answer :
Sharpstown	10
Central	11
Saline	10
Ann Arbor	10 */

-- 6. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
SELECT bw.borrower_BorrowerName, bw.borrower_BorrowerAddress, COUNT(*) AS num_books_checked_out
FROM borrower as bw
JOIN book_loans as bl ON bw.borrower_CardNo = bl.book_loans_CardNo
GROUP BY bw.borrower_CardNo
HAVING COUNT(*) > 5;
/*  Answer:
Joe Smith	1321 4th Street, New York, NY 10014	7
Tom Li	981 Main Street, Ann Arbor, MI 48104	13
Tom Haverford	23 75th Street, New York, NY 10014	6  */

-- 7. For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
SELECT b.book_Title, bc.book_copies_No_Of_Copies,a.book_authors_AuthorName, lb.library_branch_BranchName
FROM books as b
JOIN book_copies as bc  ON b.book_BookID = bc.book_copies_BookID
JOIN authors as a ON b.book_BookID = a.book_authors_BookID
JOIN library_branch as lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
WHERE a.book_authors_AuthorName = 'Stephen King'
AND lb.library_branch_BranchName = 'Central';
/*  Answer :
It	5	Stephen King	Central
The Green Mile	5	Stephen King	Central */







