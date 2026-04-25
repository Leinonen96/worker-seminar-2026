package com.jttam.glig.domain.application;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.jttam.glig.domain.application.dto.ApplicationResponse;
import com.jttam.glig.domain.application.dto.MyApplicationDTO;
import com.jttam.glig.domain.application.dto.TaskApplicantDto;
import com.jttam.glig.domain.application.dto.UpdateApplicationStatusRequest;
import com.jttam.glig.domain.application.dto.ApplicationRequest;
import com.jttam.glig.domain.task.Task;
import com.jttam.glig.domain.task.TaskRepository;
import com.jttam.glig.domain.task.TaskControllerService;
import com.jttam.glig.domain.task.TaskStatus;
import com.jttam.glig.domain.task.dto.TaskResponse;
import com.jttam.glig.domain.user.User;
import com.jttam.glig.domain.user.UserControllerService;
import com.jttam.glig.domain.user.UserRepository;
import com.jttam.glig.exception.custom.ForbiddenException;
import com.jttam.glig.exception.custom.NotFoundException;
import com.jttam.glig.service.Message;

import jakarta.persistence.criteria.Predicate;
import jakarta.transaction.Transactional;
import org.springframework.security.oauth2.jwt.Jwt;

@Service
public class ApplicationControllerService {

    private final ApplicationRepository applyRepository;
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final TaskControllerService taskControllerService;
    private final ApplicationMapper mapper;
    private final UserControllerService userControllerService;

    public ApplicationControllerService(ApplicationRepository applyRepository, 
                                    TaskRepository taskRepository,
                                    UserRepository userRepository, 
                                    TaskControllerService taskControllerService, 
                                    ApplicationMapper mapper,
                                    UserControllerService userControllerService) { 
    this.applyRepository = applyRepository;
    this.taskRepository = taskRepository;
    this.userRepository = userRepository;
    this.taskControllerService = taskControllerService;
    this.mapper = mapper;
    this.userControllerService = userControllerService;
}

    public Application tryGetSingleApplicationByUsernameAndTaskId(Long taskId, String username) {
        ApplicationId applyId = new ApplicationId(taskId, username);
        Application apply = applyRepository.findById(applyId)
                .orElseThrow(() -> new NotFoundException("APPLY_NOT_FOUND",
                        "Cannot find apply with given details " + applyId.toString()));
        return apply;
    }

    @Transactional
    public ApplicationResponse tryGetSingleApplicationResponseByUsernameAndTaskId(Long taskId, String username) {
        Application application = tryGetSingleApplicationByUsernameAndTaskId(taskId, username);
        ApplicationResponse applyDto = mapper.toApplicationResponse(application);
        return applyDto;
    }

    @Transactional
    public Page<MyApplicationDTO> GetAllUserApplications(Pageable pageable,
            ApplicationDataGridFilters filters,
            String username) {
        Long taskId = null;
        Specification<Application> spec = withApplicationFilters(filters, username, taskId);
        Page<Application> applies = applyRepository.findAll(spec, pageable);
        Page<MyApplicationDTO> listOfApplyDto = mapper.toMyApplicationDtoListPage(applies);
        return listOfApplyDto;
    }

    @Transactional
    public Page<TaskApplicantDto> tryGetAllApplicationsByGivenTaskId(Pageable pageable,
            ApplicationDataGridFilters filters, Long taskId) {
        String username = null;
        Specification<Application> spec = withApplicationFilters(filters, username, taskId);
        Page<Application> applies = applyRepository.findAll(spec, pageable);
        Page<TaskApplicantDto> listOfApplyDto = mapper.toTaskApplicantListPage(applies);
        return listOfApplyDto;
    }

    @Transactional
    public ResponseEntity<?> tryCreateNewApplicationForTask(Long taskId, ApplicationRequest application, Jwt jwt) {
        User user = userControllerService.getOrCreateUser(jwt);
        ApplicationId applyId = new ApplicationId(taskId, user.getUserName());
        if (applyRepository.existsById(applyId)) {
            return new ResponseEntity<Message>(new Message("ERROR", "User has already applied for this task"),
                    HttpStatus.CONFLICT);
        }

        Task task = taskRepository.getReferenceById(taskId);
        Application newApply = mapper.toApplicationEntity(application);
        newApply.setUser(user);
        newApply.setTask(task);
        
        Application saved = applyRepository.save(newApply);
        ApplicationResponse response = mapper.toApplicationResponse(saved);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @Transactional
    public ResponseEntity<ApplicationResponse> tryEditApplication(Long taskId, ApplicationRequest request,
            String username) {
        Application apply = tryGetSingleApplicationByUsernameAndTaskId(taskId, username);
        Application updatedApply = mapper.updateApplication(request, apply);
        Application saved = applyRepository.save(updatedApply);
        ApplicationResponse response = mapper.toApplicationResponse(saved);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @Transactional
    public ResponseEntity<Message> tryDeleteApplication(Long taskId, String username) {
        ApplicationId applyId = new ApplicationId(taskId, username);
        if (!applyRepository.existsById(applyId)) {
            throw new NotFoundException("APPLY_NOT_FOUND", "Cannot find apply with given details to delete");
        }
        applyRepository.deleteById(applyId);
        return new ResponseEntity<>(new Message("SUCCESS", "Apply deleted successfully"), HttpStatus.OK);
    }

    public Specification<Application> withApplicationFilters(ApplicationDataGridFilters filters,
            String username, Long taskId) {
        return (root, query, criteriabuilder) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (username != null) {
                predicates.add(criteriabuilder.equal(root.get("user").get("userName"), username));
            }

            if (taskId != null) {
                predicates.add(criteriabuilder.equal(root.get("task").get("id"), taskId));
            }

            if (filters != null) {

                if (filters.applicationStatus() != null) {
                    predicates.add(criteriabuilder.equal(root.get("applicationStatus"), filters.applicationStatus()));
                }

                if (filters.applicationMinPrice() != null) {
                    predicates
                            .add(criteriabuilder.greaterThanOrEqualTo(root.get("priceSuggestion"),
                                    filters.applicationMinPrice()));
                }

                if (filters.applicationMaxPrice() != null) {
                    predicates.add(criteriabuilder.lessThanOrEqualTo(root.get("priceSuggestion"),
                            filters.applicationMaxPrice()));
                }

                if (filters.categories() != null && !filters.categories().isEmpty()) {
                    Predicate categoryPredicate = root.join("task").join("categories").get("title")
                            .in(filters.categories());
                    predicates.add(categoryPredicate);
                }

                if (filters.applicationStatus() != null) {
                    predicates.add(criteriabuilder.equal(root.get("applicationStatus"), filters.applicationStatus()));
                }

                if (filters.searchText() != null && !filters.searchText().isBlank()) {
                    String searchPattern = "%" + filters.searchText().toLowerCase() + "%";
                    Predicate titleMatch = criteriabuilder.like(criteriabuilder.lower(root.get("task").get("title")),
                            searchPattern);
                    Predicate descriptionMatch = criteriabuilder.like(criteriabuilder.lower(root.get("description")),
                            searchPattern);
                    predicates.add(criteriabuilder.or(titleMatch, descriptionMatch));
                }

            }
            return criteriabuilder.and(predicates.toArray(new Predicate[0]));
        };

    }

    public ResponseEntity<ApplicationResponse> tryUpdateApplicationStatus(Long taskId, String applicantUsername,
            UpdateApplicationStatusRequest statusRequest, String taskOwnerUsername) {

        Application application = tryGetSingleApplicationByUsernameAndTaskId(taskId, applicantUsername);
        Task task = application.getTask();
        Application updatedApplication = new Application();

        if (application.getApplicationStatus() != ApplicationStatus.PENDING) {
            throw new IllegalStateException("Application has already been processed.");
        }

        if (!task.getUser().getUserName().equals(taskOwnerUsername)) {
            throw new ForbiddenException("FORBIDDEN", "User is not owner of the task");
        }

        if (statusRequest.status() == ApplicationStatus.ACCEPTED) {
            Set<Application> applications = applyRepository.findAllApplicationsByUserNameAndTaskId(taskId,
                    applicantUsername);
            applications.stream().forEach(a -> a.setApplicationStatus(ApplicationStatus.REJECTED));
            applyRepository.saveAll(applications);

            task.setStatus(TaskStatus.IN_PROGRESS);
            taskRepository.save(task);

            application.setApplicationStatus(statusRequest.status());
            updatedApplication = applyRepository.save(application);

        } else if (statusRequest.status() == ApplicationStatus.REJECTED) {
            application.setApplicationStatus(statusRequest.status());
            updatedApplication = applyRepository.save(application);

        } else {
            throw new IllegalStateException(
                    "Application can only be updated to REJECTED or ACCEPTED using this endpoint");
        }

        ApplicationResponse response = mapper.toApplicationResponse(updatedApplication);
        return new ResponseEntity<>(response, HttpStatus.OK);

    }

    @Transactional
    public ResponseEntity<TaskResponse> tryCompleteApplication(Long taskId, String username) {
        return taskControllerService.tryUpdateTaskStatus(taskId, TaskStatus.PENDING_APPROVAL, username);
    }

}
